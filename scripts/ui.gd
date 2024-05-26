extends Control


const BG_DURATION = 2.0 # BG が何秒かけて移動するか
const LABEL_DURATION = 0.5 # 数値系が何秒かけて変わるか


@export var _gear_shop: GearShop

@export var _score_level_label: Label
@export var _score_money_label: Label
@export var _score_extra_label: Label
@export var _score_score_label: Label

@export var _rank_meter: Control

@export var _body_panel: Panel
@export var _title_label: Label
@export var _gears_label: Label
@export var _next_label: RichTextLabel

@export var _help_pause_label: Label
@export var _help_jump_label: Label
@export var _help_retry_label: Label

@export var _bg: ParallaxBackground


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

	_next_label.text = "NEXT:\n..."

	# _on_state_changed() の TITLE と同じ処理
	# _ready() 内で 初期 state が変わるので connect() が追い付かない
	_body_panel.visible = true
	_title_label.text = "GABSURF"
	_help_pause_label.visible = true
	_help_jump_label.visible = true
	_help_retry_label.visible = false
	_refresh_gear_label()


# 入力制御
func _input(event):
	if event is InputEventKey:
		# キーボードが押されたとき
		if event.pressed:
			match event.keycode:
				KEY_SPACE:
					_on_jump_button_down()
					Global.can_hero_jump = false
				KEY_ESCAPE:
					_on_pause_button_down()
				KEY_ENTER:
					_on_retry_button_down()
		# キーボードが離されたとき
		else:
			Global.can_hero_jump = true


func _on_jump_button_down():
	# タイトル or ポーズ中: Body を非表示にする
	var states = [Global.State.TITLE, Global.State.PAUSED]
	if states.has(Global.state):
		_body_panel.visible = false
		_help_pause_label.visible = false
		_help_jump_label.visible = false
		_help_retry_label.visible = false

	Global.ui_jumped.emit()


func _on_pause_button_down():
	# ゲーム中: Body (画面中央 UI) を表示する
	if Global.state == Global.State.ACTIVE:
		_body_panel.visible = true
		_title_label.text = "PAUSED"
		_help_pause_label.visible = false
		_help_jump_label.visible = true
		_help_retry_label.visible = true

	Global.ui_paused.emit()


func _on_retry_button_down():
	Global.ui_retried.emit()


func _on_state_changed(_from):
	match Global.state:
		Global.State.TITLE:
			_body_panel.visible = true
			_title_label.text = "GABSURF"
			_help_pause_label.visible = true
			_help_jump_label.visible = true
			_help_retry_label.visible = false
		Global.State.GAMEOVER:
			_body_panel.visible = true
			_title_label.text = "GAME OVER"
			_help_pause_label.visible = false
			_help_jump_label.visible = false
			_help_retry_label.visible = true

	_refresh_gear_label()


func _on_rank_changed(_from):
	var _rank_y_positions = {
		Global.Rank.WHITE: -320,
		Global.Rank.BLUE: -240,
		Global.Rank.GREEN: -160,
		Global.Rank.RED: -80,
		Global.Rank.GOLD: 0
	}
	var _position = Vector2(0, _rank_y_positions[Global.rank])

	if _bg_tween:
		_bg_tween.kill()
	_bg_tween = create_tween()
	_bg_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_bg_tween.tween_property(_bg, "offset", _position, BG_DURATION)


func _on_level_changed(from):
	if _level_tween:
		_level_tween.kill()
	_level_tween = create_tween()
	_level_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_level_tween.tween_method(func(v): _score_level_label.text = str(v), from, Global.level, LABEL_DURATION)


func _on_money_changed(from):
	if _money_tween:
		_money_tween.kill()
	_money_tween = create_tween()
	_money_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_money_tween.tween_method(func(v): _score_money_label.text = str(v), from, Global.money, LABEL_DURATION)


func _on_extra_changed(from):
	if _extra_tween:
		_extra_tween.kill()
	_extra_tween = create_tween()
	_extra_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_extra_tween.tween_method(func(v): _score_extra_label.text = str(v), from, Global.extra, LABEL_DURATION)


func _on_score_changed(from):
	var _meter_position
	if 0 < Global.score:
		_meter_position = Vector2(0, -1632 + log(Global.score) / log(10) * 256)
	else:
		_meter_position = Vector2(0, -1632)

	if _score_tween:
		_score_tween.kill()
	_score_tween = create_tween()
	_score_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_score_tween.set_parallel(true)
	_score_tween.tween_method(func(v): _score_score_label.text = str(v), from, Global.score, LABEL_DURATION)
	_score_tween.tween_property(_rank_meter, "position", _meter_position, LABEL_DURATION)


func _refresh_gear_label():
	var _text = "Gears: {"
	for g in Global.gears:
		var _info = _gear_shop.get_info(g)
		_text += _info["title"] + ","
	_text += "}"

	_gears_label.text = _text
