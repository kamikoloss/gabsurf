extends CharacterBody2D


# Nodes
@onready var _hero_sprite = $AnimatedSprite2D
@onready var _collision_circle = $CollisionCircle
@onready var _life_label = $UI/Life

# Constants
const JUMP_VELOCITY = -600 # ジャンプの速度 (px/s)
const FALL_VELOCITY = 2400 # 落下速度 (px/s)
const FALL_VELOCITY_MAX = 300 # 終端速度 (px/s)
const DEAD_VELOCITY = Vector2(200, -800) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION_SPEED = -20 # 死んだときに回転するスピード


func _ready():
	Global.game_ended.connect(_on_game_ended)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.hero_damged.connect(_on_hero_damaged)
	Global.life_changed.connect(_on_life_changed)


func _physics_process(delta):
	# ゲーム中 or ゲームオーバー:
	# 終端速度に達するまで加速する
	var states = [Global.GameState.ACTIVE, Global.GameState.GAMEOVER]
	if (states.has(Global.game_state)):
		if (velocity.y < FALL_VELOCITY_MAX):
			velocity.y += FALL_VELOCITY * delta

	# ゲーム中: 横に動き続ける + 落下する
	if (Global.game_state == Global.GameState.ACTIVE):
		velocity.x = Global.hero_move_velocity
		move_and_slide()

	# ゲームオーバー: 回転する + 落下する
	# 吹き飛ぶ処理は _on_game_ended() 内でやる
	if (Global.game_state == Global.GameState.GAMEOVER):
		_hero_sprite.rotation += DEAD_ROTATION_SPEED * delta
		move_and_slide()


func _on_game_ended():
	# 吹き飛ぶ
	velocity = DEAD_VELOCITY
	_hero_sprite.stop()
	_hero_sprite.play("die")


func _on_ui_jumped():
	# ゲームオーバー以外: ジャンプする
	# タイトル or ポーズ中: 再開と同時にジャンプする
	if (Global.game_state != Global.GameState.GAMEOVER):
		velocity.y = JUMP_VELOCITY
		_hero_sprite.stop()
		_hero_sprite.play("jump")


func _on_hero_damaged():
	# ダメージを受けたがまだゲーム中 = 残機がある場合
	if (Global.game_state == Global.GameState.ACTIVE):
		# コケる
		_hero_sprite.stop()
		_hero_sprite.play("die")
		await get_tree().create_timer(0.5).timeout
		_hero_sprite.stop()
		_hero_sprite.play("default")


func _on_life_changed(value):
	var _life_text = ""
	for n in value:
		_life_text += "♥"
	_life_label.text = _life_text


func _on_area_2d_area_entered(area):
	if (area.is_in_group("Wall")):
		if (!Global.is_hero_anti_damage):
			print("Hero is damged.")
			Global.hero_damged.emit()

	if (area.is_in_group("Level")):
		print("Hero got level.")
		Global.hero_got_level.emit()

	if (area.is_in_group("Money")):
		print("Hero got money.")
		Global.hero_got_money.emit()
		area.queue_free()

	if (area.is_in_group("Shop")):
		print("Hero entered shop.")
		Global.hero_entered_shop.emit()

	if (area.is_in_group("Gear")):
		var _shop = area.get_node("../../")
		var _gear = area.get_node("../")
		var _is_gear_a = area.global_position.y < 320 # TODO: ひどい
		var _gear_type = _shop.gear_a if _is_gear_a else _shop.gear_b 
		if (Global.money < Gear.GEAR_INFO[_gear_type]["c"]):
			# 所持金が足りない場合: 買えない
			print("No money!!")
		else:
			print("Hero got gear {0}.".format([_gear_type]))
			Global.hero_got_gear.emit(_gear_type)
			_gear.queue_free()


func _on_area_2d_area_exited(area):
	if (area.is_in_group("Shop")):
		print("Hero exited shop.")
		Global.hero_exited_shop.emit()
