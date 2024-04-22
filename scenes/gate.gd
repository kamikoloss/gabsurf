extends Node2D


# Nodes
@onready var _gate_top = $Gates/GateTop
@onready var _gate_bottom = $Gates/GateBottom

# Constants
const DESTROY_TIME = 5 # 生まれて何秒後に自身を破壊するか

# Variables
var gap = 0 # ゲートの開き (デフォルト: 256px)


func _ready():
	_gate_top.position.y -= gap / 2
	_gate_bottom.position.y += gap / 2
	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	print("Gate is destroyed.")
	queue_free()
