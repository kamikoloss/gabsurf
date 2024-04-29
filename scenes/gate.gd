extends Node2D


# Nodes
@onready var _gate_top = $Mask/Gates/GateTop
@onready var _gate_bottom = $Mask/Gates/GateBottom
@onready var _money = $Mask/Gates/Money

# Variables
var gap_diff = 0 # ゲートがデフォルトから何 px 開くか
var height_diff = 0 # ゲートがデフォルトから何 px 上下に移動するか


func _ready():
	# ゲートの開き
	_gate_top.position.y -= gap_diff / 2
	_gate_bottom.position.y += gap_diff / 2

	# ゲートの座標
	_gate_top.position.y += height_diff
	_gate_bottom.position.y += height_diff
	_money.position.y += height_diff


func _on_area_2d_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("Wall is destroyed.")
		queue_free()
