extends Node2D


@export var _icon: TextureRect
@export var _title_label: RichTextLabel
@export var _desc_label: Label
@export var _desc2_label: Label
@export var _cost_label: Label
@export var _max_label: Label
@export var _color_panel: Panel
@export var _touch_area: Area2D


var stage_type: Global.Stage = Global.Stage.NONE
var gear_type: Gear.GearType = Gear.GearType.NONE


func _ready():
	Global.hero_got_gear.connect(_on_hero_got_gear)
	_icon.visible = false
	_title_label.visible = false
	_desc_label.visible = false
	_desc2_label.visible = false
	_cost_label.visible = false
	_max_label.visible = false


# Gear 用の UI を設定する
func initialize_gear(gear_info):
	_icon.visible = true
	_title_label.visible = true
	_desc_label.visible = true
	_cost_label.visible = true
	_max_label.visible = true
	_icon.texture = gear_info["icon"]
	_title_label.text = gear_info["title"]
	_desc_label.text = gear_info["desc"]
	_cost_label.text = gear_info["cost"]
	_max_label.text = gear_info["max"]


# Stage 用の UI を設定する
func initialize_stage():
	pass


# Panel の色を変更する
func _change_panel_color(color):
	var style = _color_panel.get_theme_stylebox("panel").duplicate()
	style.bg_color = color
	_color_panel.add_theme_stylebox_override("panel", style)


func _on_hero_got_gear(gear):
	if gear == gear_type:
		_touch_area.queue_free()
		_change_panel_color(Color(0.5, 0.25, 0.25)) # グレーがかった緑
