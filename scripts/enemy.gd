extends Area2D


const FALL_VELOCITY = Vector2(0, 800) # 落下速度
const DEAD_VELOCITY = Vector2(400, -400) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION = 20 # 死んだときに回転するスピード
const DEAD_COLOR = Color(0, 0, 255) # 死んだときになる色


@export var _sprite: AnimatedSprite2D


var is_active = false # 倒される対象として有効かどうか
var is_dead = false # もう倒されたあとかどうか
var speed = 50 # 飛行速度 (px/s)


var _dead_velocity = Vector2.ZERO # 死んだときの落下速度


func _process(delta):
	position.x -= speed * delta

	if is_dead:
		position += _dead_velocity * delta
		rotation += DEAD_ROTATION * delta
		_dead_velocity += FALL_VELOCITY * delta


func _on_area_entered(area):
	if area.is_in_group("Screen"):
		is_active = true

	if area.is_in_group("Hero"):
		if Global.gears.has(Global.GearType.BDA):
			_die()

	if area.is_in_group("Weapon"):
		if is_active and !is_dead:
			_die()


func _on_area_exited(area):
	if area.is_in_group("Screen"):
		#print("[Enemy] destroyed.")
		queue_free()


func _die():
	is_dead = true

	_dead_velocity = DEAD_VELOCITY
	_sprite.self_modulate = DEAD_COLOR

	#print("[Enemy] dead.")
	Global.enemy_dead.emit()
