extends Area2D


#Nodes
@onready var _sprite = $AnimatedSprite2D

# Variables
var is_dead = false
var speed = 40 # 飛行速度 (px/s)

var _dead_velocity = Vector2.ZERO

# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか
const FALL_VELOCITY = Vector2(0, 800) # 落下速度
const DEAD_VELOCITY = Vector2(400, -400) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION = 20 # 死んだときに回転するスピード
const DEAD_COLOR = Color(0, 0, 255) # 死んだときになる色


func _ready():
	_destroy()


func _process(delta):
	position.x -= speed * delta

	if is_dead:
		_dead_velocity += FALL_VELOCITY * delta
		position += _dead_velocity * delta
		rotation += DEAD_ROTATION * delta


func die():
	is_dead = true
	_dead_velocity = DEAD_VELOCITY
	_sprite.modulate = DEAD_COLOR


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Enemy is destroyed.")
	queue_free()
