extends Node2D

# Nodes
@onready var _enter_label = $Enter/VBoxContainer/Label2
@onready var _exit_label = $Exit/VBoxContainer/Label2
@onready var _gear_ui = {
	"a": {
		"parent": $GearA,
		"title": $GearA/Text/MarginContainer/VBoxContainer/Title,
		"desc": $GearA/Text/MarginContainer/VBoxContainer/Description,
		"cost": $GearA/Money/Label,
		"icon": $GearA/Image, 
	},
	"b": {
		"parent": $GearB,
		"title": $GearB/Text/MarginContainer/VBoxContainer/Title,
		"desc": $GearB/Text/MarginContainer/VBoxContainer/Description,
		"cost": $GearB/Money/Label,
		"icon": $GearB/Image, 
	},
}

# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか

# Variables
var number = 0
var gate_gap = 0 # TODO: 難易度なので Global においてもいい？
var gear = { "a": null, "b": null }


func _ready():
	_enter_label.text = str(number)
	_exit_label.text = str(gate_gap)

	# 店に並べるギアを2つ抽選する
	gear["a"] = Gear.get_random_gear()
	gear["b"] = Gear.get_random_gear(gear["a"])
	print("Gears are {0} and {1}.".format([gear["a"], gear["b"]]))

	# 店にギアを並べる
	for k in ["a", "b"]:
		if gear[k] == null:
			_gear_ui[k]["parent"].queue_free()
		else:
			var _gear_info = Gear.get_gear_ui(gear[k])
			_gear_ui[k]["title"].text = _gear_info["t"]
			_gear_ui[k]["desc"].text = _gear_info["d"]
			_gear_ui[k]["cost"].text = _gear_info["c"]
			_gear_ui[k]["icon"].texture = _gear_info["i"]

	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Shop is destroyed.")
	queue_free()
