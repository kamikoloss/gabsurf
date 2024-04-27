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
var gear_a = null
var gear_b = null


func _ready():
	_enter_label.text = str(number)
	_exit_label.text = str(gate_gap)
	
	# 店に並べるギアを2つ抽選する
	# 被らないようにする
	# TODO: 最大保持数を超えているギアは出現させないようにする
	gear_a = Gear.get_random_gear()
	for n in 100:
		gear_b = Gear.get_random_gear()
		if gear_a != gear_b:
			break
	print("Gears are {0} and {1}.".format([gear_a, gear_b]))

	# 店にギアを並べる
	_gear_a_label_title.text = Gear.GEAR_INFO[gear_a]["t"]
	_gear_a_label_description.text = Gear.GEAR_INFO[gear_a]["d"]
	_gear_a_sprite.texture = Gear.ITEM_SPRITES[Gear.GEAR_INFO[gear_a]["i"]]
	_gear_b_label_title.text = Gear.GEAR_INFO[gear_b]["t"]
	_gear_b_label_description.text = Gear.GEAR_INFO[gear_b]["d"]
	_gear_b_sprite.texture = Gear.ITEM_SPRITES[Gear.GEAR_INFO[gear_b]["i"]]

	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Shop is destroyed.")
	queue_free()
