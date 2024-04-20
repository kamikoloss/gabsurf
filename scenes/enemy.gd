extends Area2D


# Variables
var speed = 50 # 飛行速度 (px/s)


func _process(delta):
	position.x -= 50 * delta
