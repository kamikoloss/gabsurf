extends Node2D


@export var _icon: TextureRect
@export var _title_label: RichTextLabel
@export var _desc_label: Label
@export var _cost_label: Label
@export var _max_label: Label
@export var _color_panel: Panel


var gear_type = null # Gear.GearType


func _ready():
	Global.hero_got_gear.connect(_on_hero_got_gear)


# Gear 用の UI を設定する
func set_gear_ui(gear_info):
	_icon.texture = gear_info["icon"]
	_title_label.text = gear_info["title"]
	_desc_label.text = gear_info["desc"]
	_cost_label.text = gear_info["cost"]
	_max_label.text = gear_info["max"]


# Panel の色を変更する
func _change_panel_color(color):
	var style = _color_panel.get_theme_stylebox("panel").duplicate()
	style.set("bg_color", color)
	_color_panel.add_theme_stylebox_override("panel", style)


func _on_hero_got_gear(gear):
	if gear == gear_type:
		_change_panel_color(Color(0.5, 0.25, 0.25))
