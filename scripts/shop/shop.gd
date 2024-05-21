extends Node2D

class_name Shop


const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか


@export var _shop_panel_scene: PackedScene
@export var _enter_label: Label
@export var _middle_panel: Panel
#@export var _middle_label: Label

@export var _gear_shop: GearShop
@export var _stage_shop: StageShop


var _is_gear_shop = false
var _is_stage_shop = false


func _ready():
	_auto_destroy()


# Gear 用の UI を設定する
func initialize_gear(number):
	_is_gear_shop = true
	_enter_label.text = str(number)
	_middle_panel.visible = false

	# Shop に並べる Gear を2つ抽選する
	var _gear = { "a": null, "b": null }
	_gear["a"] = _gear_shop.get_random_gear()
	_gear["b"] = _gear_shop.get_random_gear(_gear["a"])
	print("[Shop] gears are {0} and {1}.".format([_gear["a"], _gear["b"]]))

	# ShopPanel を2つ生成する
	var _panel_position_y = { "a": 120, "b": 400 }
	for k in ["a", "b"]:
		if _gear[k] == null:
			return
		var _gear_info = _gear_shop.get_gear_ui(_gear[k])
		var _shop_panel = _shop_panel_scene.instantiate()
		_shop_panel.position.y = _panel_position_y[k]
		_shop_panel.gear_type = _gear[k]
		_shop_panel.buy_area_entered.connect(_on_buy_area_entered)
		add_child(_shop_panel)
		_shop_panel.initialize_gear(_gear_info)


# Stage 用の UI を設定する
func initialize_stage():
	_is_stage_shop = true
	pass


# 指定秒数後に自身を破壊する
func _auto_destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("[Shop] destroyed.")
	queue_free()


func _on_buy_area_entered(type):
	if _is_gear_shop:
		var _cost = _gear_shop.get_gear_cost(type) * Global.MONEY_RATIO
		# Money が足りない場合: 買えない
		if Global.money < _cost:
			print("[Shop] try to get gear, but no money!! (money: {0}, cost: {1})".format([Global.money, _cost]))
		# Money が足りる場合
		else:
			Global.money -= _cost
			Global.shop_through_count = 0
			Global.gears += [type]
			print("[Shop] got gear {0}. (cost: {1})".format([type, _cost]))
			Global.hero_got_gear.emit(type)
