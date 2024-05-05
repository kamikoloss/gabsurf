extends Area2D


#Nodes
@onready var _sprite = $AnimatedSprite2D


# Variables
var is_active = false
var is_dead = false
var speed = 50 # 飛行速度 (px/s)

var _dead_velocity = Vector2.ZERO # 死んだときの落下速度


# Constants
const FALL_VELOCITY = Vector2(0, 800) # 落下速度
const DEAD_VELOCITY = Vector2(400, -400) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION = 20 # 死んだときに回転するスピード
const DEAD_COLOR = Color(0, 0, 255) # 死んだときになる色


func die():
	is_dead = true
	_dead_velocity = DEAD_VELOCITY
	_sprite.modulate = DEAD_COLOR


func _process(delta):
	position.x -= speed * delta

	if is_dead:
		_dead_velocity += FALL_VELOCITY * delta
		position += _dead_velocity * delta
		rotation += DEAD_ROTATION * delta


func _on_area_entered(area):
	if area.is_in_group("ScreenIn"):
		is_active = true


func _on_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("[Enemy] destroyed.")
		queue_free()
