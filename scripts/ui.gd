extends Control


@export var _bg: ParallaxBackground
@export var _header_level_label: Label
@export var _header_money_label: Label
@export var _header_extra_label: Label
@export var _header_score_label: Label
@export var _footer_pause_label: Label
@export var _footer_jump_label: Label
@export var _footer_retry_label: Label
@export var _body_panel: Panel
@export var _title_label: Label
@export var _gears_label: Label


const BG_DURATION = 2.0 # BG が何秒かけて移動するか
const LABEL_DURATION = 0.5 # 数値系が何秒かけて変わるか


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

	# _on_state_changed() の TITLE と同じ処理
	# _ready() 内で 初期 state が変わるので connect() が追い付かない
	_body_panel.visible = true
	_title_label.text = "GABSURF"
	_footer_pause_label.visible = true
	_footer_jump_label.visible = true
	_footer_retry_label.visible = false
	_refresh_label_gear()


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
		_footer_pause_label.visible = false
		_footer_jump_label.visible = false
		_footer_retry_label.visible = false

	Global.ui_jumped.emit()


func _on_pause_button_down():
	# ゲーム中: Body (画面中央 UI) を表示する
	if Global.state == Global.State.ACTIVE:
		_body_panel.visible = true
		_title_label.text = "PAUSED"
		_footer_pause_label.visible = false
		_footer_jump_label.visible = true
		_footer_retry_label.visible = true
		_refresh_label_gear()

	Global.ui_paused.emit()


func _on_retry_button_down():
	Global.ui_retried.emit()


func _on_state_changed(from):
	match Global.state:
		Global.State.TITLE:
			_body_panel.visible = true
			_title_label.text = "GABSURF"
			_footer_pause_label.visible = true
			_footer_jump_label.visible = true
			_footer_retry_label.visible = false
		Global.State.GAMEOVER:
			_body_panel.visible = true
			_title_label.text = "GAME OVER"
			_footer_pause_label.visible = false
			_footer_jump_label.visible = false
			_footer_retry_label.visible = true

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
	_tween.tween_method(func(v): _header_level_label.text = str(v), from, Global.level, LABEL_DURATION)


func _on_money_changed(from):
	var _tween = _get_money_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _header_money_label.text = str(v), from, Global.money, LABEL_DURATION)


func _on_extra_changed(from):
	var _tween = _get_extra_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _header_extra_label.text = str(v), from, Global.extra, LABEL_DURATION)


func _on_score_changed(from):
	var _tween = _get_score_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(func(v): _header_score_label.text = str(v), from, Global.score, LABEL_DURATION)


func _refresh_label_gear():
	var _gears = "Gears: {"
	for gear in Gear.my_gears:
		_gears += Gear.gear_info[gear]["t"]
		_gears += ","
	_gears += "}"
	_gears_label.text = _gears


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
