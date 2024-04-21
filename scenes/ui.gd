extends Control


@onready var _body_labels = $CanvasLayer/Layout/Body/Labels
@onready var _label_title = $CanvasLayer/Layout/Body/Labels/Title
@onready var _label_description = $CanvasLayer/Layout/Body/Labels/Description
@onready var _label_level = $CanvasLayer/Layout/Header/VBoxContainer/Level/Label
@onready var _label_money = $CanvasLayer/Layout/Header/VBoxContainer/Money/Label
@onready var _label_extra = $CanvasLayer/Layout/Header/VBoxContainer/Extra/Label
@onready var _label_score = $CanvasLayer/Layout/Header/VBoxContainer/Score/Label


func _ready():
	# Signal 接続
	Global.game_initialized.connect(_on_game_initialized)
	Global.game_ended.connect(_on_game_ended)
	Global.level_changed.connect(_on_level_changed)
	Global.money_changed.connect(_on_money_changed)
	Global.extra_changed.connect(_on_extra_changed)
	Global.score_changed.connect(_on_score_changed)
	Global.life_changed.connect(_on_life_changed)


# 入力制御
func _input(event):
	if event is InputEventKey:
		# キーボードが押されたとき
		if event.pressed:
			match event.keycode:
				KEY_SPACE:
					_on_jump_button_down()
				KEY_ESCAPE:
					_on_pause_button_down()
				KEY_ENTER:
					_on_retry_button_down()


func _on_jump_button_down():
	# タイトル or ポーズ中: Body を非表示にする
	var states = [Global.GameState.TITLE, Global.GameState.PAUSED]
	if (states.has(Global.game_state)):
		_body_labels.visible = false

	Global.ui_jumped.emit()


func _on_pause_button_down():
	# ゲーム中: Body を表示する
	if (Global.game_state == Global.GameState.ACTIVE):
		_body_labels.visible = true
		_label_title.text = "PAUSED"
		_label_description.text = "▲ / Space でゲーム再開\n● / Enter でリトライ"

	Global.ui_paused.emit()


func _on_retry_button_down():
	Global.ui_retried.emit()


func _on_game_initialized():
	_body_labels.visible = true
	_label_title.text = "GABSURF"
	_label_description.text = "▲ / Space でゲーム開始\n■ / Esc でポーズ"


func _on_game_ended():
	_body_labels.visible = true
	_label_title.text = "GAME OVER"
	_label_description.text = "● / Enter でリトライ"


func _on_level_changed(value):
	_label_level.text = "LEVEL\n{0}".format([value])


func _on_money_changed(value):
	_label_money.text = "MONEY\n{0}".format([value])


func _on_extra_changed(value):
	_label_extra.text = "EXTRA\n{0}".format([value])


func _on_score_changed(value):
	_label_score.text = "SCORE\n{0}".format([value])


func _on_life_changed(value):
	pass # TODO
