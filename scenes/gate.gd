extends Node2D


# Nodes
@onready var _gate_top = $Mask/Gates/GateTop
@onready var _gate_bottom = $Mask/Gates/GateBottom
@onready var _money = $Mask/Gates/Money

# Constants
const DESTROY_TIME = 5 # 生まれて何秒後に自身を破壊するか

# Variables
var gap = 0 # ゲートがデフォルトから何 px 開くか
var height_diff = 0 # ゲートがデフォルトから何 px 上下に移動するか


func _ready():
	# ゲートの開き
	_gate_top.position.y -= gap / 2
	_gate_bottom.position.y += gap / 2

	# ゲートの上下
	_gate_top.position.y += height_diff
	_gate_bottom.position.y += height_diff
	_money.position.y += height_diff

	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Gate is destroyed.")
	queue_free()
