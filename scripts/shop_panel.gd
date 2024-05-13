extends Node2D


@export var _icon: TextureRect
@export var _title_label: RichTextLabel
@export var _desc_label: Label
@export var _cost_label: Label
@export var _max_label: Label


# Gear 用の UI を設定する
func set_gear_ui(gear_info):
	_icon.texture = gear_info["icon"]
	_title_label.text = gear_info["title"]
	_desc_label.text = gear_info["desc"]
	_cost_label.text = gear_info["cost"]
	_max_label.text = gear_info["max"]
