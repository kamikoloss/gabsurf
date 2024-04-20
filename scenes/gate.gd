extends Node2D


# Nodes
@onready var _gate_top = $GateTop
@onready var _gate_bottom = $GateBottom

# Constants
var DESTROY_TIME = 5 # 生まれて何秒後に自身を破壊するか

# Variables
var gap = 1.0 # ゲートの開き具合 (x128px)


func _ready():
	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	print("Gate is destroyed.")
	queue_free()
