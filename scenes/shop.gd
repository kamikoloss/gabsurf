extends Node2D

# Nodes
@onready var _enter_label = $Enter/VBoxContainer/Label2
@onready var _exit_label = $Exit/VBoxContainer/Label2
@onready var _gear_a_label_title = $GearA/Text/MarginContainer/HBoxContainer/VBoxContainer/Title
@onready var _gear_a_label_description = $GearA/Text/MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var _gear_a_sprite = $GearA/Image
@onready var _gear_b_label_title = $GearB/Text/MarginContainer/HBoxContainer/VBoxContainer/Title
@onready var _gear_b_label_description = $GearB/Text/MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var _gear_b_sprite = $GearB/Image

# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか

# Variables
var number = 0
var gate_gap = 0


func _ready():
	_enter_label.text = str(number)
	_exit_label.text = str(gate_gap)
	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	print("Shop is destroyed.")
	queue_free()
