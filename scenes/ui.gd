extends Control


@onready var _labels = $CanvasLayer/Layout/Body/Labels
@onready var _label_title = $CanvasLayer/Layout/Body/Labels/Title
@onready var _label_desc = $CanvasLayer/Layout/Body/Labels/Description
@onready var _label_money = $CanvasLayer/Layout/Header/VBoxContainer2/Money


func _ready():
	# Signal 接続
	Global.game_initialized.connect(_on_game_initialized)
	Global.game_ended.connect(_on_game_ended)
	Global.game_paused.connect(_on_game_paused)
	Global.game_resumed.connect(_on_game_resumed)	
	Global.money_changed.connect(_on_money_changed)


func _on_game_initialized():
	_labels.visible = true


func _on_game_ended():
	_labels.visible = true
	_label_title.text = "GAMEOVER"
	_label_desc.text = "Press ▲/Space to surf again."


func _on_game_paused():
	_labels.visible = true
	_label_title.text = "PAUSED"
	_label_desc.text = "Press ▲/Space to resume."


func _on_game_resumed():
	_labels.visible = false


func _on_money_changed(value):
	_label_money.text = "MONEY\n{0}".format([value])
