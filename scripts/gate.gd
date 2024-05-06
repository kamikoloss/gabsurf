extends Node2D


# Nodes
@onready var _gate_top = $Mask/Gates/GateTop
@onready var _gate_bottom = $Mask/Gates/GateBottom
@onready var _money = $Mask/Gates/Money


# Variables
var gap_diff = 0 # Gate がデフォルトから何 px 開くか
var height_diff = 0 # Gate がデフォルトから何 px 上下に移動するか
var set_money = true # Gate の真ん中に Money を配置するか


func _ready():
	# Gate を開く
	_gate_top.position.y -= gap_diff / 2
	_gate_bottom.position.y += gap_diff / 2

	# Gate の Y 座標を移動する
	_gate_top.position.y += height_diff
	_gate_bottom.position.y += height_diff
	_money.position.y += height_diff

	# Money を配置する
	if !set_money:
		_money.queue_free()


func _on_area_2d_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("[Gate] destroyed.")
		queue_free()
