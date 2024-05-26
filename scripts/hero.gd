extends CharacterBody2D


const JUMP_COOLTIME = 0.05 # (s)
const JUMP_VELOCITY = -600 # ジャンプの速度 (px/s)
const FALL_VELOCITY = 2400 # 落下速度 (px/s)
const FALL_VELOCITY_MAX = 300 # 終端速度 (px/s)

const MOVE_VELOCITY_DEFAULT = 200.0 # 移動速度のデフォルト値 (px/s)
const MOVE_ACCELARATE_DULATION = 1.0 # 加速が終わる時間 (s)

const DEAD_VELOCITY = Vector2(200, -800) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION = -20 # 死んだときに回転する速度

const ANTI_DAMAGE_DURATION = 1.0 # Hero が被ダメージ時に何秒間無敵になるか


@export var _weapon_scene: PackedScene

@export var _shoes: Area2D
@export var _hero_sprite: AnimatedSprite2D
@export var _jump_particles: GPUParticles2D

@export var _jump_label: Label
@export var _shoes_texture: TextureRect
@export var _anti_damage_bar: TextureProgressBar
@export var _life_label: Label


var _is_anti_damage = false # Hero が無敵状態かどうか

var _move_velocity = MOVE_VELOCITY_DEFAULT # 横移動の速度 (px/s)

var _jump_counter_weapon = 0
var _jump_counter_weapon_quota = 9999 # Gear 取得時に変更

var _accelerate_tween = null
var _anti_damage_tween = null


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_touched_damage.connect(_on_hero_touched_damage)
	Global.hero_got_damage.connect(_on_hero_got_damage)
	Global.enemy_dead.connect(_on_enemy_dead)

	_anti_damage_bar.visible = false

	_shoes.remove_from_group("Weapon")
	_jump_label.visible = false
	_shoes_texture.visible = false


func _physics_process(delta):
	# ゲーム中 or ゲームオーバー:
	# 終端速度に達するまで加速する
	var states = [Global.State.ACTIVE, Global.State.GAMEOVER]
	if states.has(Global.state):
		if velocity.y < FALL_VELOCITY_MAX:
			velocity.y += FALL_VELOCITY * delta

	# ゲーム中: 横に動き続ける + 落下する
	if Global.state == Global.State.ACTIVE:
		velocity.x = _move_velocity
		move_and_slide()

	# ゲームオーバー: 回転する + 落下する
	# 吹き飛ぶ処理は _on_state_changed() 内でやる
	if Global.state == Global.State.GAMEOVER:
		_hero_sprite.rotation += DEAD_ROTATION * delta
		move_and_slide()


func _on_state_changed(_from):
	match Global.state:
		Global.State.GAMEOVER:
			# 吹き飛ぶ
			velocity = DEAD_VELOCITY
			# コケる
			_hero_sprite.stop()
			_hero_sprite.play("die")
			# 残機表示なし
			_life_label.text = ""


func _on_ui_jumped():
	# ゲームオーバー: 何もしない
	if Global.state == Global.State.GAMEOVER:
		return
	# ゲーム中 and ジャンプできない: 何もしない
	if Global.state == Global.State.ACTIVE and !Global.can_hero_jump:
		return
	# ゲーム中 or タイトル or ポーズ中: 再開と同時にジャンプする

	# ジャンプ (縦方向)
	var _jump_velocity_y = JUMP_VELOCITY
	if Global.gears.has(Global.GearType.JMV):
		var _jmv = [null, 0.9, 0.8, 0.7]
		var _jmv_count = Global.gears.count(Global.GearType.JMV)
		_jump_velocity_y *= _jmv[_jmv_count]
	velocity.y = _jump_velocity_y

	# 加速 (横方向)
	if Global.gears.has(Global.GearType.JMA):
		var _jma = [null, 200, 400, 600]
		var _jma_count = Global.gears.count(Global.GearType.JMA)
		_accelerate_move(_jma[_jma_count], MOVE_ACCELARATE_DULATION)

	# アニメーション
	_hero_sprite.stop()
	_hero_sprite.play("jump")

	# パーティクル
	var _jump_particle_clone = _jump_particles.duplicate()
	_jump_particle_clone.finished.connect(func(): _jump_particle_clone.queue_free())
	add_child(_jump_particle_clone)
	_jump_particle_clone.restart()

	# ミサイル系
	if Global.gears.has(Global.GearType.MSB):
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
			var _weapon = _weapon_scene.instantiate()
			_weapon.position = position
			get_tree().root.add_child(_weapon)


func _on_hero_got_gear(gear):
	match gear:
		Global.GearType.MSB:
			_jump_label.visible = true
			var _msb = [null, 5, 3, 2]
			var _msb_count = Global.gears.count(Global.GearType.MSB)
			_jump_counter_weapon_quota = _msb[_msb_count]
		Global.GearType.SCL:
			_move_velocity *= 1.25
			Global.extra *= 2
		Global.GearType.SHO:
			_shoes_texture.visible = true
			_shoes.add_to_group("Weapon")


func _on_hero_touched_damage():
	# ゲーム中でない: ダメージを受けても何も起きない
	if Global.state != Global.State.ACTIVE:
		return

	# 無敵状態: ダメージを受けない
	if _is_anti_damage:
		return

	# それ以外: ダメージを受ける
	# Life を減らす
	Global.life -= 1
	print("[Hero] damged.")
	Global.hero_got_damage.emit()


func _on_hero_got_damage():
	# コケる
	_hero_sprite.stop()
	_hero_sprite.play("die")

	# Life 表示を更新する
	var _life_text = ""
	for n in Global.life:
		_life_text += "♥"
	_life_label.text = _life_text

	# Life が 0 (以下) になった場合
	if Global.life <= 0:
		# ゲームオーバー
		Global.state = Global.State.GAMEOVER
	# Life がまだある場合
	else:
		# 無敵状態に突入する
		_enter_anti_damage(ANTI_DAMAGE_DURATION)
		# コケから戻る
		await get_tree().create_timer(0.5).timeout
		_hero_sprite.stop()
		_hero_sprite.play("default")


func _on_enemy_dead():
	# ATD
	if Global.gears.has(Global.GearType.ATD):
		var _atd = [0, 1, 2, 3]
		var _atd_count = Global.gears.count(Global.GearType.ATD)
		_enter_anti_damage(_atd[_atd_count])


func _on_body_area_entered(area):
	if Global.state != Global.State.ACTIVE:
		return

	if area.is_in_group("Wall"):
		#print("[Hero] touched walls.")
		Global.hero_touched_damage.emit()

	if area.is_in_group("Enemy"):
		if area.is_active and !area.is_dead:
			#print("[Hero] touched a enemy.")
			Global.hero_touched_damage.emit()

	if area.is_in_group("Level"):
		#print("[Hero] got level.")
		Global.hero_got_level.emit()

	if area.is_in_group("Money"):
		#print("[Hero] got money.")
		area.queue_free()
		Global.hero_got_money.emit()

	if area is ShopArea:
		print("[Hero] entered shop.")
		Global.hero_entered_shop.emit(area.shop_type)


func _on_body_area_exited(area):
	if Global.state != Global.State.ACTIVE:
		return

	# ゲーム中に　Hero が画面外に出た場合: 強制ゲームーオーバー
	if area.is_in_group("Screen"):
		print("[Hero] exited screen.")
		Global.state = Global.State.GAMEOVER

	if area is ShopArea:
		print("[Hero] exited shop.")
		Global.hero_exited_shop.emit(area.shop_type)


# 横移動の速度を一時的に加速する
func _accelerate_move(speed_diff, duration):
	var _from = MOVE_VELOCITY_DEFAULT + speed_diff
	var _to = MOVE_VELOCITY_DEFAULT

	if _accelerate_tween:
		_accelerate_tween.kill()
	_accelerate_tween = create_tween()
	_accelerate_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_accelerate_tween.tween_method(func(v): _move_velocity = v, _from, _to, duration)


# 無敵状態に突入する
func _enter_anti_damage(duration):
	_is_anti_damage = true
	_anti_damage_bar.visible = true
	_anti_damage_bar.value = 100

	if _anti_damage_tween:
		_anti_damage_tween.kill()
	_anti_damage_tween = create_tween()
	_anti_damage_tween.set_trans(Tween.TRANS_LINEAR)
	_anti_damage_tween.tween_property(_anti_damage_bar, "value", 0, duration)
	_anti_damage_tween.tween_callback(func(): _anti_damage_bar.visible = false)
	_anti_damage_tween.tween_callback(func(): _is_anti_damage = false)
	#_tween.tween_callback(func(): print("[Game] anti-damage is finished."))
