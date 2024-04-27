extends Node2D

# Nodes
@onready var _enter_label = $Enter/VBoxContainer/Label2
@onready var _exit_label = $Exit/VBoxContainer/Label2

@onready var _gear_a_parent = $GearA
@onready var _gear_a_label_title = $GearA/Text/MarginContainer/HBoxContainer/VBoxContainer/Title
@onready var _gear_a_label_description = $GearA/Text/MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var _gear_a_sprite = $GearA/Image
@onready var _gear_b_parent = $GearB
@onready var _gear_b_label_title = $GearB/Text/MarginContainer/HBoxContainer/VBoxContainer/Title
@onready var _gear_b_label_description = $GearB/Text/MarginContainer/HBoxContainer/VBoxContainer/Description
@onready var _gear_b_sprite = $GearB/Image

# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか

# Variables
var number = 0
var gate_gap = 0 # TODO: 難易度なので Global においてもいい？
var gear_a = null
var gear_b = null


func _ready():
	_enter_label.text = str(number)
	_exit_label.text = str(gate_gap)
	
	# 店に並べるギアを2つ抽選する
	gear_a = Gear.get_random_gear()
	gear_b = Gear.get_random_gear(gear_a)
	print("Gears are {0} and {1}.".format([gear_a, gear_b]))

	# 店にギアを並べる
	if (gear_a == null):
		_gear_a_parent.queue_free()
	else:
		_gear_a_label_title.text = Gear.GEAR_INFO[gear_a]["t"]
		_gear_a_label_description.text = Gear.GEAR_INFO[gear_a]["d"]
		_gear_a_sprite.texture = Gear.ITEM_SPRITES[Gear.GEAR_INFO[gear_a]["i"]]

	if (gear_b == null):
		_gear_b_parent.queue_free()
	else:
		_gear_b_label_title.text = Gear.GEAR_INFO[gear_b]["t"]
		_gear_b_label_description.text = Gear.GEAR_INFO[gear_b]["d"]
		_gear_b_sprite.texture = Gear.ITEM_SPRITES[Gear.GEAR_INFO[gear_b]["i"]]

	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Shop is destroyed.")
	queue_free()
