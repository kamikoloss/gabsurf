extends Control


# Nodes
@onready var _bg = $ParallaxBackground
@onready var _label_level = $CanvasLayer/Header/Level/VBoxContainer/Label2
@onready var _label_money = $CanvasLayer/Header/Money/VBoxContainer/Label2
@onready var _label_extra = $CanvasLayer/Header/Extra/VBoxContainer/Label2
@onready var _label_score = $CanvasLayer/Header/Score/VBoxContainer/Label2
@onready var _panel_body = $CanvasLayer/Layout/Body/Panel
@onready var _label_title = $CanvasLayer/Layout/Body/Panel/Labels/Title
@onready var _label_gears = $CanvasLayer/Layout/Body/Panel/Labels/Gears # Debug
@onready var _footer_pause = $CanvasLayer/Footer/Pause
@onready var _footer_jump = $CanvasLayer/Footer/Jump
@onready var _footer_retry = $CanvasLayer/Footer/Retry

# Constants
const BG_DURATION = 2.0 # BG が何秒かけて上昇するか
const LABEL_DURATION = 0.5 # 数値系が何秒かけて変わるか

# Variables
var _bg_tween = null
var _level_tween = null
var _money_tween = null
var _extra_tween = null
var _score_tween = null


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.rank_changed.connect(_on_rank_changed)
	Global.level_changed.connect(_on_level_changed)
	Global.money_changed.connect(_on_money_changed)
	Global.extra_changed.connect(_on_extra_changed)
	Global.score_changed.connect(_on_score_changed)


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
	var states = [Global.State.TITLE, Global.State.PAUSED]
	if states.has(Global.state):
		_panel_body.visible = false
		_footer_pause.visible = false
		_footer_jump.visible = false
		_footer_retry.visible = false

	Global.ui_jumped.emit()


func _on_pause_button_down():
	# ゲーム中: Body (画面中央 UI) を表示する
	if Global.state == Global.State.ACTIVE:
		_panel_body.visible = true
		_label_title.text = "PAUSED"
		_footer_pause.visible = false
		_footer_jump.visible = true
		_footer_retry.visible = true
		_refresh_label_gear()

	Global.ui_paused.emit()


func _on_retry_button_down():
	Global.ui_retried.emit()


func _on_state_changed(from):
	match Global.state:
		Global.State.TITLE:
			_panel_body.visible = true
			_label_title.text = "GABSURF"
			_footer_pause.visible = true
			_footer_jump.visible = true
			_footer_retry.visible = false
		Global.State.GAMEOVER:
			_panel_body.visible = true
			_label_title.text = "GAME OVER"
			_footer_pause.visible = false
			_footer_jump.visible = false
			_footer_retry.visible = true
	_refresh_label_gear()


func _on_rank_changed(from):
	var _rank_y_positions = {
		Global.Rank.WHITE: -320,
		Global.Rank.BLUE: -240,
		Global.Rank.GREEN: -160,
		Global.Rank.RED: -80,
		Global.Rank.GOLD: 0
	}
	var _position = Vector2(0, _rank_y_positions[Global.rank])

	var _tween = _get_bg_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(_bg, "offset", _position, BG_DURATION)


func _on_level_changed(from):
	var _tween = _get_level_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _label_level.text = str(v), from, Global.level, LABEL_DURATION)


func _on_money_changed(from):
	var _tween = _get_money_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _label_money.text = str(v), from, Global.money, LABEL_DURATION)


func _on_extra_changed(from):
	var _tween = _get_extra_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _label_extra.text = str(v), from, Global.extra, LABEL_DURATION)


func _on_score_changed(from):
	var _tween = _get_score_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _label_score.text = str(v), from, Global.score, LABEL_DURATION)


func _refresh_label_gear():
	var _gears = "Gears: {"
	for gear in Gear.my_gears:
		_gears += Gear.GEAR_INFO[gear]["t"]
		_gears += ","
	_gears += "}"
	_label_gears.text = _gears


func _get_bg_tween():
	if _bg_tween:
		_bg_tween.kill()
	_bg_tween = create_tween()
	return _bg_tween

func _get_level_tween():
	if _level_tween:
		_level_tween.kill()
	_level_tween = create_tween()
	return _level_tween


func _get_money_tween():
	if _money_tween:
		_money_tween.kill()
	_money_tween = create_tween()
	return _money_tween


func _get_extra_tween():
	if _extra_tween:
		_extra_tween.kill()
	_extra_tween = create_tween()
	return _extra_tween


func _get_score_tween():
	if _score_tween:
		_score_tween.kill()
	_score_tween = create_tween()
	return _score_tween
