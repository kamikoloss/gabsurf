extends Node2D


# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか


func _ready():
	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	print("Shop is destroyed.")
	queue_free()
