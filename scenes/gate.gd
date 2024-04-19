extends Node2D


# Constants
const INITIAL_X_POSITION = 400 # 初期 X 座標

# Variables
var height = 0 # ゲートの高さ 0 で上下中央
var gap_ratio = 1 # ゲートがどれだけ開いているかの倍率 (x128px)
var speed = 200 # ゲートが迫ってくる速さ (px/s)

# Nodes
@onready var _gate_top = $GateTop
@onready var _gate_bottom = $GateBottom


func _ready():
	# Group 設定
	_gate_top.add_to_group("Wall")
	_gate_bottom.add_to_group("Wall")
	# 初期化
	position.x = INITIAL_X_POSITION
	position.y += height


func _process(delta):
	position.x -= speed * delta
