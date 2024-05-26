extends Node2D
class_name ShopPanel


signal buy_area_entered


@export var _icon: TextureRect
@export var _title_label: RichTextLabel
@export var _desc_label_1: Label
@export var _desc_label_2: Label

@export var _cost_panel: Panel
@export var _cost_label: Label

@export var _buy_panel: Panel
@export var _buy_area: Area2D

@export var _max_panel: Panel
@export var _max_label: Label


var gear_type = Global.GearType.NONE
var stage_type = Global.StageType.NONE


func _ready():
	_buy_area.area_entered.connect(_on_buy_area_entered)


# Gear 用の UI を設定する
func setup_gear_ui(gear_info):
	_desc_label_2.visible = false

	_icon.texture = gear_info["icon"]
	_title_label.text = gear_info["title"]
	_desc_label_1.text = gear_info["desc"]
	_cost_label.text = gear_info["cost"]
	_max_label.text = gear_info["max"]


# Stage 用の UI を設定する
func setup_stage_ui(stage_info):
	_icon.visible = false
	_desc_label_2.visible = false
	_cost_panel.visible = false
	_max_panel.visible = false

	_title_label.text = stage_info["title"]
	_desc_label_1.text = stage_info["desc"]


# Buy Panel の色を変更する
func _change_panel_color(color):
	var _style = _buy_panel.get_theme_stylebox("panel").duplicate()
	_style.bg_color = color
	_buy_panel.add_theme_stylebox_override("panel", _style)


func _on_buy_area_entered(area):
	if !area.is_in_group("Hero"):
		return

	if gear_type != Global.GearType.NONE:
		buy_area_entered.emit(gear_type)
	if stage_type != Global.StageType.NONE:
		buy_area_entered.emit(stage_type)

	_buy_area.queue_free()
	_change_panel_color(Color(0.5, 0.25, 0.25)) # グレーがかった緑
