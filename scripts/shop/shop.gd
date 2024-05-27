extends Node2D
class_name Shop


const SHOP_PANEL_POSITION_Y = { "a": 120, "b": 400 }


@export var _shop_panel_scene: PackedScene

@export var _shop_area: ShopArea

@export var _enter_label_1: Label
@export var _enter_label_2: Label
@export var _middle_panel: Panel
@export var _middle_label: Label

@export var _gear_shop: GearShop
@export var _stage_shop: StageShop


func _ready():
	_shop_area.area_exited.connect(_on_shop_area_exited)
	_middle_panel.visible = false


# Gear 用の UI を設定する
func setup_gear_ui(shop_count):
	_shop_area.shop_type = Global.ShopType.GEAR

	_enter_label_1.text = "SHOP"
	_enter_label_2.text = str(shop_count)

	# Shop に並べる Gear を2つ抽選する
	var _active_types = _gear_shop.get_active_types()
	var _gears = { "a": null, "b": null }
	_gears["a"] = _get_random_type(_active_types)
	_gears["b"] = _get_random_type(_active_types, _gears["a"])
	print("[Shop] gears are {0} and {1}.".format([_gears["a"], _gears["b"]]))

	# ShopPanel を2つ生成する
	for k in ["a", "b"]:
		if _gears[k] == null:
			return
		var _gear_info = _gear_shop.get_info(_gears[k])
		var _shop_panel = _shop_panel_scene.instantiate()
		_shop_panel.position.y = SHOP_PANEL_POSITION_Y[k]
		_shop_panel.gear_type = _gears[k]
		_shop_panel.buy_area_entered.connect(_on_gear_shop_buy_area_entered)
		add_child(_shop_panel)
		_shop_panel.setup_gear_ui(_gear_info)


# Stage 用の UI を設定する
func setup_stage_ui():
	_shop_area.shop_type = Global.ShopType.STAGE

	_middle_panel.visible = true

	_enter_label_1.text = "STAGE"
	_enter_label_2.text = str(Global.stage_number + 1)
	_middle_label.text = "LEVEL will be reset to 0."

	# Shop に並べる Stage を2つ抽選する
	var _active_types = _stage_shop.get_active_types()
	var _stages = { "a": null, "b": null }
	_stages["a"] = _get_random_type(_active_types)
	_stages["b"] = _get_random_type(_active_types, _stages["a"])
	print("[Shop] stages are {0} and {1}.".format([_stages["a"], _stages["b"]]))

	# ShopPanel を2つ生成する
	for k in ["a", "b"]:
		if _stages[k] == null:
			return
		var _stage_info = _stage_shop.get_info(_stages[k])
		var _shop_panel = _shop_panel_scene.instantiate()
		_shop_panel.position.y = SHOP_PANEL_POSITION_Y[k]
		_shop_panel.stage_type = _stages[k]
		_shop_panel.buy_area_entered.connect(_on_stage_shop_buy_area_entered)
		add_child(_shop_panel)
		_shop_panel.setup_stage_ui(_stage_info)


func _on_shop_area_exited(area):
	if area.is_in_group("Screen"):
		#print("[Shop] destroyed.")
		queue_free()


# ランダムな値を抽選する
# 抽選に失敗した場合は null を返す
func _get_random_type(active_types, ignore_type = null):
	var _type = null # 抽選結果

	for n in 10:
		# 選択肢が存在しない場合: 中止
		if active_types.size() == 0:
			break

		# 抽選する
		var _random = active_types[randi() % active_types.size()]

		# 避ける Gear が抽選された場合: NG 次のループへ
		if _random == ignore_type:
			continue

		# OK
		_type = _random
		break

	return _type


func _on_gear_shop_buy_area_entered(shop_panel: ShopPanel, gear_type: Global.GearType):
	var _cost = _gear_shop.get_cost(gear_type) * Global.MONEY_RATIO

	# Money が足りない場合: 買えない
	if Global.money < _cost:
		shop_panel.change_panel_color(Color(0.2, 0.2, 0.2)) # グレー
		print("[Shop] try to get gear, but no money!! (money: {0}, cost: {1})".format([Global.money, _cost]))
	# Money が足りる場合
	else:
		shop_panel.change_panel_color(Color(0.4, 0.2, 0.2)) # グレーがかった赤
		Global.money -= _cost
		Global.shop_through_count = 0
		Global.gears += [gear_type]
		print("[Shop] got gear {0}. (cost: {1})".format([gear_type, _cost]))
		# TODO: signal の命名ルールから外れている
		Global.hero_got_gear.emit(gear_type)


func _on_stage_shop_buy_area_entered(shop_panel: ShopPanel, stage_type: Global.StageType):
	shop_panel.change_panel_color(Color(0.4, 0.2, 0.2)) # グレーがかった赤

	Global.stage = stage_type
	Global.level = 0
