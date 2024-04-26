extends Area2D


#Nodes
@onready var _sprite = $AnimatedSprite2D

# Variables
var is_dead = false
var speed = 50 # 飛行速度 (px/s)


# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか
const DEAD_VELOCITY = Vector2(200, -800) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION_SPEED = 20 # 死んだときに回転するスピード
#const DEAD_COLOR = 


func _ready():
	_destroy()


func _process(delta):
	position.x -= 50 * delta

	if (is_dead):
		position += DEAD_VELOCITY * delta
		rotation += DEAD_ROTATION_SPEED * delta


func die():
	is_dead = true
	_sprite.modulate = Color(0, 0, 255)


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Enemy is destroyed.")
	queue_free()
