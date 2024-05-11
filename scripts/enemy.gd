extends Area2D


# Exports
@export var _sprite: Node


# Variables
var is_dead = false # もう倒されたあとかどうか
var speed = 50 # 飛行速度 (px/s)

var _is_active = false # 倒される対象として有効かどうか
var _dead_velocity = Vector2.ZERO # 死んだときの落下速度


# Constants
const FALL_VELOCITY = Vector2(0, 800) # 落下速度
const DEAD_VELOCITY = Vector2(400, -400) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION = 20 # 死んだときに回転するスピード
const DEAD_COLOR = Color(0, 0, 255) # 死んだときになる色


func _process(delta):
	position.x -= speed * delta

	if is_dead:
		position += _dead_velocity * delta
		rotation += DEAD_ROTATION * delta
		_dead_velocity += FALL_VELOCITY * delta


func _on_area_entered(area):
	if area.is_in_group("ScreenIn"):
		_is_active = true

	if area.is_in_group("Hero"):
		if Gear.my_gears.has(Gear.GearType.BDA):
			_die()

	if area.is_in_group("Weapon"):
		if !is_dead and _is_active:
			_die()


func _on_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("[Enemy] destroyed.")
		queue_free()


func _die():
	is_dead = true
	_dead_velocity = DEAD_VELOCITY
	_sprite.modulate = DEAD_COLOR
	print("[Enemy] dead.")
	Global.enemy_dead.emit()
