extends Node2D


# Variables
var gap = 1 # ゲートの開き具合 (x128px)
var speed = 200 # ゲートが迫ってくる速さ (px/s)

# Nodes
@onready var _gate_top = $GateTop
@onready var _gate_bottom = $GateBottom


func _ready():
	# Group 設定
	_gate_top.add_to_group("Wall")
	_gate_bottom.add_to_group("Wall")


func _process(delta):
	position.x -= speed * delta
