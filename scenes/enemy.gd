extends Area2D


# Variables
var speed = 50 # 飛行速度 (px/s)

# Constants
const DESTROY_TIME = 5 # 生まれて何秒後に自身を破壊するか


func _ready():
	_destroy()


func _process(delta):
	position.x -= 50 * delta


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Enemy is destroyed.")
	queue_free()
