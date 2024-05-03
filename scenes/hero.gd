extends CharacterBody2D

# Scenes
const WEAPON_SCENE = preload("res://scenes/weapon.tscn")

# Nodes
@onready var _hero_sprite = $AnimatedSprite2D
@onready var _collision_circle = $CollisionCircle
@onready var _jump_label = $UI/Jump
@onready var _life_label = $UI/Life

# Variables
var _jump_timer = 0
var _jump_counter_weapon = 0
var _jump_counter_weapon_quota = 99 # Gear 取得時に変更

# Constants
const JUMP_COOLTIME = 0.05 # (s)
const JUMP_VELOCITY = -600 # ジャンプの速度 (px/s)
const FALL_VELOCITY = 2400 # 落下速度 (px/s)
const FALL_VELOCITY_MAX = 300 # 終端速度 (px/s)
const DEAD_VELOCITY = Vector2(200, -800) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION = -20 # 死んだときに回転する速度


func _ready():
	Global.game_ended.connect(_on_game_ended)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.life_changed.connect(_on_life_changed)

	_jump_label.visible = false


func _physics_process(delta):
	_jump_timer += delta
	
	# ゲーム中 or ゲームオーバー:
	# 終端速度に達するまで加速する
	var states = [Global.State.ACTIVE, Global.State.GAMEOVER]
	if states.has(Global.state):
		if velocity.y < FALL_VELOCITY_MAX:
			velocity.y += FALL_VELOCITY * delta

	# ゲーム中: 横に動き続ける + 落下する
	if Global.state == Global.State.ACTIVE:
		velocity.x = Global.hero_move_velocity
		move_and_slide()

	# ゲームオーバー: 回転する + 落下する
	# 吹き飛ぶ処理は _on_game_ended() 内でやる
	if Global.state == Global.State.GAMEOVER:
		_hero_sprite.rotation += DEAD_ROTATION * delta
		move_and_slide()


func _on_game_ended():
	# 吹き飛ぶ
	velocity = DEAD_VELOCITY
	_hero_sprite.stop()
	_hero_sprite.play("die")


func _on_ui_jumped():
	# ゲームオーバー: 何もしない
	if Global.state == Global.State.GAMEOVER:
		return

	# クールタイム中: 何もしない
	if Global.state == Global.State.ACTIVE && _jump_timer < JUMP_COOLTIME:
		return

	# ゲーム中 or タイトル or ポーズ中: 再開と同時にジャンプする
	velocity.y = JUMP_VELOCITY
	_hero_sprite.stop()
	_hero_sprite.play("jump")
	_jump_timer = 0

	# MSB 所持中
	if Gear.my_gears.has(Gear.GearType.MSB):
		_jump_counter_weapon += 1

		var _jump_text = ""
		for n in _jump_counter_weapon:
			_jump_text += "●"
		for n in (_jump_counter_weapon_quota - _jump_counter_weapon):
			_jump_text += "○"
		_jump_label.text = _jump_text

		if _jump_counter_weapon_quota <= _jump_counter_weapon:
			_jump_counter_weapon = 0
			# ミサイルを発射する
			var _weapon = WEAPON_SCENE.instantiate()
			_weapon.position = position
			get_tree().root.get_node("Main").add_child(_weapon)


func _on_hero_got_gear(gear):
	match gear:
		Gear.GearType.MSB:
			_jump_label.visible = true
			var _msb = [5, 3, 2]
			var _msb_count = Gear.my_gears.count(Gear.GearType.MSB) # 増える前の数
			_jump_counter_weapon_quota = _msb[_msb_count]


func _on_life_changed(from):
	var _life_text = ""
	for n in Global.life:
		_life_text += "♥"
	_life_label.text = _life_text

	# ダメージを受けたがまだ残機がある場合: コケる
	if Global.state == Global.State.ACTIVE && Global.life < from:
		_hero_sprite.stop()
		_hero_sprite.play("die")
		await get_tree().create_timer(0.5).timeout
		# NOTE: ゲームオーバー時は 0.5 秒後 ACTIVE じゃないので "default" に戻らない
		# TODO: ごちゃごちゃしているので整理する
		if Global.state == Global.State.ACTIVE:
			_hero_sprite.stop()
			_hero_sprite.play("default")


func _on_body_area_entered(area):
	if Global.state != Global.State.ACTIVE:
		return

	if area.is_in_group("Wall"):
		if Global.is_hero_anti_damage:
			return
		print("Hero is damged by wall.")
		Global.hero_damged.emit()

	if area.is_in_group("Enemy"):
		if area.is_dead or Global.is_hero_anti_damage:
			return
		if Gear.my_gears.has(Gear.GearType.BDA):
			area.die() # area = enemy
			print("Hero kills enemy.")
			Global.hero_kills_enemy.emit()
			return

		print("Hero is damged by enemy.")
		Global.hero_damged.emit()

	if area.is_in_group("Level"):
		print("Hero got level.")
		Global.hero_got_level.emit()

	if area.is_in_group("Money"):
		print("Hero got money.")
		area.queue_free()
		Global.hero_got_money.emit()

	if area.is_in_group("Shop"):
		print("Hero entered shop.")
		Global.hero_entered_shop.emit()

	if area.is_in_group("Gear"):
		var _shop = area.get_node("../../")
		var _is_gear_a = area.get_node("../").position.y < 0
		var _gear = _shop.gear["a"] if _is_gear_a else _shop.gear["b"]
		var _cost = Gear.GEAR_INFO[_gear]["c"]
		if Global.money < _cost:
			# 所持金が足りない場合: 買えない
			print("No money!! (money: {0}, cost: {1})".format([Global.money, _cost]))
		else:
			area.get_node("../Image").queue_free()
			area.queue_free()
			print("Hero got gear {0}. (cost: {1})".format([Gear.GEAR_INFO[_gear]["t"], _cost]))
			Global.hero_got_gear.emit(_gear)


func _on_body_area_exited(area):
	if Global.state != Global.State.ACTIVE:
		return

	# ゲーム中に　Hero が画面外に出た場合: 強制ゲームーオーバー
	if area.is_in_group("ScreenOut"):
		print("Hero exited screen.")
		Global.game_ended.emit()

	if area.is_in_group("Shop"):
		print("Hero exited shop.")
		Global.hero_exited_shop.emit()


func _on_shoes_area_entered(area):
	if Global.state != Global.State.ACTIVE:
		return

	if area.is_in_group("Enemy"):
		if area.is_dead:
			return
		if Gear.my_gears.has(Gear.GearType.SHO):
			print("Hero kills enemy.")
			area.die() # area = enemy
			Global.hero_kills_enemy.emit()
