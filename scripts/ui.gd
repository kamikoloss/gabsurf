extends Control


const BG_DURATION = 2.0 # BG が何秒かけて移動するか
const LABEL_DURATION = 0.5 # 数値系が何秒かけて変わるか


@export var _gear_shop: GearShop

# Buttons
@export var _center_button: Button
@export var _left_button: Button
@export var _right_button: Button

# Score
@export var _score_level_label: Label
@export var _score_money_label: Label
@export var _score_extra_label: Label
@export var _score_score_label: Label
@export var _rank_meter: Control
@export var _stage_label: RichTextLabel
@export var _next_label: RichTextLabel

# Pause UI
@export var _body_panel: Panel
@export var _title_label: Label
@export var _version_label: Label
@export var _gears_label: RichTextLabel
@export var _help_pause_label: Label
@export var _help_jump_label: Label
@export var _help_retry_label: Label

# BG
@export var _bg_parallax: ParallaxBackground
@export var _bg_color: TextureRect


var _level_tween = null
var _money_tween = null
var _extra_tween = null
var _score_tween = null
var _bg_parallax_position_tween = null
var _bg_color_tween = null


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.stage_changed.connect(_on_stage_changed)
	Global.rank_changed.connect(_on_rank_changed)
	Global.level_changed.connect(_on_level_changed)
	Global.money_changed.connect(_on_money_changed)
	Global.extra_changed.connect(_on_extra_changed)
	Global.score_changed.connect(_on_score_changed)

	_center_button.button_down.connect(_on_center_button_down)
	_center_button.button_up.connect(_on_center_button_up)
	_left_button.button_down.connect(_on_left_button_down)
	_right_button.button_down.connect(_on_right_button_down)

	# UI 初期化
	_show_pause_ui(Global.State.TITLE)
	_refresh_stage_label()
	_version_label.text = Global.VERSION


# 入力制御
func _input(event):
	# キーボード
	if event is InputEventKey:
		# 押されたとき
		if event.pressed:
			match event.keycode:
				KEY_SPACE:
					_on_center_button_down()
				KEY_ESCAPE:
					_on_left_button_down()
				KEY_ENTER:
					_on_right_button_down()
		# 離されたとき
		else:
			match event.keycode:
				KEY_SPACE:
					_on_center_button_up()


func _on_state_changed(_from):
	if Global.state == Global.State.ACTIVE:
		_hide_pause_ui()
	else:
		_show_pause_ui(Global.state)


func _on_stage_changed(_from):
	_refresh_stage_label()

	# BG の背景色を変更する
	var _cartain_color = Color(0.2, 0.2, 0.2)
	var _after_color: Color

	match Global.stage:
		Global.StageType.B:
			_after_color = Color(0.4, 0.2, 0.2, 0.2)
		Global.StageType.C:
			_after_color = Color(0.4, 0.2, 0.2, 0.2)
		Global.StageType.D:
			_after_color = Color(0.2, 0.2, 0.4, 0.2)
		Global.StageType.E:
			_after_color = Color(0.2, 0.2, 0.4, 0.8) # 視界が悪い
		Global.StageType.X:
			_after_color = Color(0.2, 0.2, 0.2, 0.2)

	if _bg_color_tween:
		_bg_color_tween.kill()
	_bg_color_tween = create_tween()
	_bg_color_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_bg_color_tween.tween_property(_bg_color, "self_modulate", _after_color, BG_DURATION)


func _on_rank_changed(_from):
	var _rank_y_positions = {
		Global.Rank.WHITE: -320,
		Global.Rank.BLUE: -240,
		Global.Rank.GREEN: -160,
		Global.Rank.RED: -80,
		Global.Rank.GOLD: 0
	}
	var _position = Vector2(0, _rank_y_positions[Global.rank])

	if _bg_parallax_position_tween:
		_bg_parallax_position_tween.kill()
	_bg_parallax_position_tween = create_tween()
	_bg_parallax_position_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_bg_parallax_position_tween.tween_property(_bg_parallax, "offset", _position, BG_DURATION)


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


func _on_center_button_down():
	#print("[UI] center button is down.")
	Global.center_button_down.emit()
	Global.can_hero_jump = false # 離したときに true に戻る


func _on_center_button_up():
	#print("[UI] center button is up.")
	Global.can_hero_jump = true


func _on_left_button_down():
	Global.left_button_down.emit()


func _on_right_button_down():
	Global.right_button_down.emit()


func _show_pause_ui(state: Global.State):
	_refresh_gear_label()
	_body_panel.visible = true

	match state:
		Global.State.TITLE:
			_title_label.text = "GABSURF"
			_help_pause_label.visible = true
			_help_jump_label.visible = true
			_help_retry_label.visible = false
		Global.State.PAUSED:
			_title_label.text = "PAUSED"
			_help_pause_label.visible = false
			_help_jump_label.visible = true
			_help_retry_label.visible = true
		Global.State.GAMEOVER:
			_title_label.text = "GAME OVER"
			_help_pause_label.visible = false
			_help_jump_label.visible = false
			_help_retry_label.visible = true


func _hide_pause_ui():
	_body_panel.visible = false
	_help_pause_label.visible = false
	_help_jump_label.visible = false
	_help_retry_label.visible = false


func _refresh_stage_label():
	# STAGE
	_stage_label.text = "STAGE: {0}".format([str(Global.stage_number)])

	# NEXT
	var _rank = ""
	var _target_rank = Global.STAGE_TARGET_RANK[Global.stage_number]
	match _target_rank:
		Global.Rank.NONE:
			_rank = "[color=#808080]NONE[/color]"
		Global.Rank.BLUE:
			_rank = "[color=#8080FF]1,000[/color]"
		Global.Rank.GREEN:
			_rank = "[color=#80FF80]10,000[/color]"
		Global.Rank.RED:
			_rank = "[color=#FF8080]100,000[/color]"
		Global.Rank.GOLD:
			_rank = "[color=#FFFF80]1,000,000[/color]"

	_next_label.text = "NEXT: " + _rank


func _refresh_gear_label():
	var _text = "Gears: {"
	for g in Global.gears:
		_text += _gear_shop.get_info(g)["title"] + ","
	_text += "}"

	_gears_label.text = _text
