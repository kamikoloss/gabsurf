extends Node


const SLOW_SPEED_GEAR_SHOP = 0.8 # Gear Shop に入ったときに何倍速のスローになるか
const SLOW_DURATION_GEAR_SHOP = 1.0 # Gear Shop に入ったときに何秒かけてスローになるか
const SLOW_SPEED_STAGE_SHOP = 0.4 # Gear Shop に入ったときに何倍速のスローになるか
const SLOW_DURATION_STAGE_SHOP = 1.0 # Gear Shop に入ったときに何秒かけてスローになるか
const SLOW_SPEED_GAMEOVER = 0.6 # ゲームオーバー時に何倍速のスローになるか
const SLOW_DURATION_GAMEOVER = 1.0 # ゲームオーバー時に何秒かけてスローになるか


@export var _bgm_player: AudioStreamPlayer
@export var _jump_sound: AudioStream
@export var _damage_sound: AudioStream
@export var _money_sound: AudioStream
@export var _gear_sound: AudioStream
@export var _stage_sound: AudioStream
@export var _gameover_sound: AudioStream
#@export var _retry_sound: AudioStream


var _slow_tween = null
var _bgm_position = null


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.stage_changed.connect(_on_stage_changed)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_got_damage.connect(_on_hero_got_damage)
	Global.hero_entered_shop.connect(_on_hero_entered_shop)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)
	Global.enemy_dead.connect(_on_enemy_dead)


func _on_state_changed(_from):
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
			_play_se(_gameover_sound)
			_enter_slow(SLOW_SPEED_GAMEOVER, SLOW_DURATION_GAMEOVER)


func _on_stage_changed(_from):
	_play_se(_stage_sound)


func _on_ui_jumped():
	if Global.state != Global.State.GAMEOVER:
		_play_se(_jump_sound)


func _on_hero_got_damage():
	_play_se(_damage_sound)


func _on_hero_got_money():
	_play_se(_money_sound)


func _on_hero_got_gear(_gear):
	_play_se(_gear_sound)


func _on_hero_entered_shop(shop_type: Global.ShopType):
	if Global.state != Global.State.ACTIVE:
		return

	if shop_type == Global.ShopType.GEAR:
		_enter_slow(SLOW_SPEED_GEAR_SHOP, SLOW_DURATION_GEAR_SHOP)
	if shop_type == Global.ShopType.STAGE:
		_enter_slow(SLOW_SPEED_STAGE_SHOP, SLOW_DURATION_STAGE_SHOP)


func _on_hero_exited_shop(shop_type: Global.ShopType):
	if Global.state != Global.State.ACTIVE:
		return

	if shop_type == Global.ShopType.GEAR:
		_exit_slow(SLOW_DURATION_GEAR_SHOP)
	if shop_type == Global.ShopType.STAGE:
		_exit_slow(SLOW_DURATION_STAGE_SHOP)


func _on_enemy_dead():
	_play_se(_damage_sound)


# SE を鳴らす
func _play_se(sound):
	var _player: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(_player)
	_player.stream = sound
	_player.volume_db = -3.0
	_player.play()
	await _player.finished
	_player.queue_free()


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
