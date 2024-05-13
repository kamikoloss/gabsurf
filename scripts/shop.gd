extends Node2D


@export var _shop_panel_scene: PackedScene
@export var _enter_label: Label


const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか


var number = 0
var gear = { "a": null, "b": null } # Gear.GearType


func _ready():
	_enter_label.text = str(number)

	# 店に並べるギアを2つ抽選する
	gear["a"] = Gear.get_random_gear()
	gear["b"] = Gear.get_random_gear(gear["a"])
	print("[Shop] gears are {0} and {1}.".format([gear["a"], gear["b"]]))

	# 店にギアを並べる
	var _panel_position_y = { "a": 120, "b": 400 }
	for k in ["a", "b"]:
		if gear[k] != null:
			var _gear_info = Gear.get_gear_ui(gear[k])
			var _gear_panel = _shop_panel_scene.instantiate()
			_gear_panel.set_gear_ui(_gear_info)
			_gear_panel.position.y = _panel_position_y[k]
			add_child(_gear_panel)

	_auto_destroy()


# 指定秒数後に自身を破壊する
func _auto_destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("[Shop] destroyed.")
	queue_free()
