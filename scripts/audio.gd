extends Node2D


# Resources
const JUMP_SOUND = preload("res://sounds/パパッ.mp3")
const MONEY_SOUND = preload("res://sounds/金額表示.mp3")
const GEAR_SOUND = preload("res://sounds/きらーん1.mp3")
const DAMAGE_SOUND = preload("res://sounds/ビシッとツッコミ2.mp3")
const GAMEOVER_SOUND = preload("res://sounds/お寺の鐘.mp3")
const RETRY_SOUND = preload("res://sounds/DJのスクラッチ1.mp3")


# Nodes
@onready var _bgm_player = $BGM
@onready var _se_player = $SE
@onready var _se_player_ui = $SE2


# Constants
const SLOW_SPEED_SHOP = 0.8 # Shop に入ったときに何倍速のスローになるか
const SLOW_DURATION_SHOP = 1.0 # Shop に入ったときに何秒かけてスローになるか
const SLOW_SPEED_GAMEOVER = 0.6 # ゲームオーバー時に何倍速のスローになるか
const SLOW_DURATION_GAMEOVER = 1.0 # ゲームオーバー時に何秒かけてスローになるか


# Variables
var _slow_tween = null
var _bgm_position = null


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_damaged.connect(_on_hero_damaged)
	Global.hero_kills_enemy.connect(_on_hero_kills_enemy)
	Global.hero_entered_shop.connect(_on_hero_entered_shop)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)


func _process(delta):
	global_position.x = get_viewport().get_camera_2d().global_position.x


func _on_state_changed(from):
	match Global.state:
		# ゲーム中
		Global.State.ACTIVE:
			# BGM を再開する
			if _bgm_position != null:
				_bgm_player.play(_bgm_position)
		# ポーズ中
		Global.State.PAUSED:
			# BGM の再開位置を保持して止める
			_bgm_position = _bgm_player.get_playback_position()
			_bgm_player.stop()
		# ゲームオーバー
		Global.State.GAMEOVER:
			_play_se(GAMEOVER_SOUND)
			_enter_slow(SLOW_SPEED_GAMEOVER, SLOW_DURATION_GAMEOVER)


func _on_ui_jumped():
	# ゲーム中
	if Global.state == Global.State.ACTIVE:
		_play_se_ui(JUMP_SOUND)


func _on_hero_damaged():
	# ゲーム中　and 残機がある and 無敵状態でない: コケる
	if  Global.state == Global.State.ACTIVE and 0<= Global.life and !Global.is_hero_anti_damage:
		_play_se(DAMAGE_SOUND)


func _on_hero_got_money():
	_play_se(MONEY_SOUND)


func _on_hero_got_gear(gear):
	_play_se(GEAR_SOUND)


func _on_hero_kills_enemy():
	_play_se(DAMAGE_SOUND)


func _on_hero_entered_shop():
	if Global.state == Global.State.ACTIVE:
		_enter_slow(SLOW_SPEED_SHOP, SLOW_DURATION_SHOP)


func _on_hero_exited_shop():
	if Global.state == Global.State.ACTIVE:
		_exit_slow(SLOW_DURATION_SHOP)


# SE を鳴らす
func _play_se(sound):
	_se_player.stop()
	_se_player.stream = sound
	_se_player.play()


# SE を鳴らす (UI)
func _play_se_ui(sound):
	_se_player_ui.stop()
	_se_player_ui.stream = sound
	_se_player_ui.play()


# スロー用の Tween を取得する
func _get_slow_tween():
	if _slow_tween:
		_slow_tween.kill()
	_slow_tween = create_tween()
	_slow_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	return _slow_tween


# 通常速度からスローになっていく
func _enter_slow(speed, duration):
	var _tween = _get_slow_tween()
	_tween.tween_property(_bgm_player, "pitch_scale", speed, duration)


# スローから通常速度になっていく
func _exit_slow(duration):
	var _tween = _get_slow_tween()
	_tween.tween_property(_bgm_player, "pitch_scale", 1.0, duration)