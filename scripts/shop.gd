extends Node2D


# Exports
@export var _enter_label: Node
@export var _a_root: Node
@export var _a_icon: Node
@export var _a_title_label: Node
@export var _a_desc_label: Node
@export var _a_cost_label: Node
@export var _a_max_label: Node
@export var _b_root: Node
@export var _b_icon: Node
@export var _b_title_label: Node
@export var _b_desc_label: Node
@export var _b_cost_label: Node
@export var _b_max_label: Node


# Constants
const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか


# Variables
var number = 0
var gear = { "a": null, "b": null } # Gear.GearType


func _ready():
	_enter_label.text = str(number)

	# 店に並べるギアを2つ抽選する
	gear["a"] = Gear.get_random_gear()
	gear["b"] = Gear.get_random_gear(gear["a"])
	print("[Shop] gears are {0} and {1}.".format([gear["a"], gear["b"]]))

	# 店にギアを並べる
	var _ui = {
		"a": {
			"root": _a_root,
			"icon": _a_icon,
			"title": _a_title_label,
			"desc": _a_desc_label,
			"cost": _a_cost_label,
			"max": _a_max_label,
		},
		"b": {
			"root": _b_root,
			"icon": _b_icon,
			"title": _b_title_label,
			"desc": _b_desc_label,
			"cost": _b_cost_label,
			"max": _b_max_label,
		},
	}

	for k in ["a", "b"]:
		if gear[k] == null:
			_ui[k]["root"].queue_free()
		else:
			var _gear_info = Gear.get_gear_ui(gear[k])
			_ui[k]["title"].text = _gear_info["title"]
			_ui[k]["desc"].text = _gear_info["desc"]
			_ui[k]["cost"].text = _gear_info["cost"]
			_ui[k]["max"].text = _gear_info["max"]
			_ui[k]["icon"].texture = _gear_info["icon"]

	_destroy()


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("[Shop] destroyed.")
	queue_free()
