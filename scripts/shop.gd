extends Node2D


@export var _shop_panel_scene: PackedScene
@export var _enter_label: Label
@export var _middle_panel: Panel
@export var _middle_label: Label


const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか


var number = 0
var gear = { "a": null, "b": null } # Gear.GearType


func _ready():
	_auto_destroy()


# Gear 用の UI を設定する
func initialize_gear():
	_enter_label.text = str(number)
	_middle_panel.visible = false

	# Shop に並べる Gear を2つ抽選する
	gear["a"] = Gear.get_random_gear()
	gear["b"] = Gear.get_random_gear(gear["a"])
	print("[Shop] gears are {0} and {1}.".format([gear["a"], gear["b"]]))

	# ShopPanel を2つ生成する
	var _panel_position_y = { "a": 120, "b": 400 }
	for k in ["a", "b"]:
		if gear[k] != null:
			var _gear_info = Gear.get_gear_ui(gear[k])
			var _shop_panel = _shop_panel_scene.instantiate()
			_shop_panel.position.y = _panel_position_y[k]
			_shop_panel.gear_type = gear[k]
			add_child(_shop_panel)
			_shop_panel.initialize_gear(_gear_info)


# Stage 用の UI を設定する
func initialize_stage():
	pass


# 指定秒数後に自身を破壊する
func _auto_destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("[Shop] destroyed.")
	queue_free()
