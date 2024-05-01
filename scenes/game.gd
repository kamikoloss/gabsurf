extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const SHOP_SCENE = preload("res://scenes/shop.tscn")

# Resources
const JUMP_SOUND = preload("res://sounds/パパッ.mp3")
const MONEY_SOUND = preload("res://sounds/金額表示.mp3")
const GEAR_SOUND = preload("res://sounds/きらーん1.mp3")
const DAMAGE_SOUND = preload("res://sounds/ビシッとツッコミ2.mp3")
const GAMEOVER_SOUND = preload("res://sounds/お寺の鐘.mp3")
const RETRY_SOUND = preload("res://sounds/DJのスクラッチ1.mp3")

# Nodes
@onready var _hero = $Hero
@onready var _hero_anti_damage_bar = $Hero/UI/TextureProgressBar
@onready var _bgm_player = $Hero/AudioPlayers/BGM
@onready var _se_player = $Hero/AudioPlayers/SE
@onready var _se_player_ui = $Hero/AudioPlayers/SE2

# Constants
const SLOW_DURATION_SHOP = 1.0 # 入店時に何秒かけてスローになるか
const SLOW_SPEED_SHOP = 0.8 # Shop 入店時に何倍速のスローになるか
const SLOW_SPEED_GAMEOVER = 0.2 # ゲームオーバー時に何倍速のスローになるか
const SLOW_DURATION_GAMEOVER = 1.0 # ゲームオーバー時に何秒かけてスローになるか
const GATE_HEIGHT_MIN = -80
const GATE_HEIGHT_MAX = 80
const GATE_GAP_STEP = 16 # ゲートが難易度上昇で何 px ずつ狭くなっていくか
const LEVEL_BASE = 10 # ゲート通過時に Level に加算される値
const ENEMY_SPAWN_COOLTIME_BASE = 3.0

# Variables
var _money_base = 1 # Money 取得時に加算される値
var _gate_gap = 0 # ゲートの開き

var _gate_counter_shop = 0 # ゲートを通るたびに 1 増加する 店が出現したら 0 に戻す
var _gate_counter_shop_quota = 3 # ゲートを何回通るたびに店が出現するか
var _gate_counter_difficult = 0 # ゲートを通るたびに 1 増加する 難易度が上昇したら 0 に戻す
var _gate_counter_difficult_quota = 3 # ゲートを何回通るたびに難易度が上昇するか
var _shop_counter = 0 # 店を生成するたびに 1 増加する

var _is_spawn_gate = false # ゲートを生成するか
var _gate_spawn_cooltime = 2.0 # 何秒ごとにゲートを生成するか
var _gate_spawn_timer = 0.0
var _is_spawn_enemy = false # 敵を生成するか
var _enemy_spawn_cooltime = ENEMY_SPAWN_COOLTIME_BASE # 何秒ごとに敵を生成するか
var _enemy_spawn_timer = 0.0
var _enemy_spawn_height_min = GATE_HEIGHT_MIN
var _enemy_spawn_height_max = GATE_HEIGHT_MAX

var _slow_tween = null
var _anti_damage_tween = null

var _bgm_position = null

var _rng = RandomNumberGenerator.new()


func _ready():
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.ui_paused.connect(_on_ui_paused)
	Global.ui_retried.connect(_on_ui_retried)
	Global.hero_damged.connect(_on_hero_damged)
	Global.hero_got_level.connect(_on_hero_got_level)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_entered_shop.connect(_on_hero_entered_shop)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_kills_enemy.connect(_on_hero_kills_enemy)

	_initialize_game()


func _process(delta):
	_process_spawn_gate(delta)
	_process_spawn_enemy(delta)


# ゲームを初期化 + 一時停止する
func _initialize_game():
	print("Waiting start...")
	Engine.time_scale = 1.0
	set_process(false)
	set_physics_process(false)

	Global.initialize()
	Gear.initialize()

	_is_spawn_gate = true
	_is_spawn_enemy = true

	_hero_anti_damage_bar.visible = false

	Global.game_initialized.emit()


func _on_ui_jumped():
	# タイトル or ポーズ中 -> ゲーム中
	var states = [Global.GameState.TITLE, Global.GameState.PAUSED]
	if states.has(Global.game_state):
		Engine.time_scale = 1.0
		set_process(true)
		set_physics_process(true)
		if (_bgm_position != null):
			_bgm_player.play(_bgm_position)
		Global.game_state = Global.GameState.ACTIVE
	
	# ゲーム中
	if Global.game_state == Global.GameState.ACTIVE:
		# SE を鳴らす
		_play_se_ui(JUMP_SOUND)



func _on_ui_paused():
	# ゲーム中 -> ポーズ中
	if Global.game_state == Global.GameState.ACTIVE:
		Engine.time_scale = 0.0
		set_process(false)
		set_physics_process(false)
		_bgm_position = _bgm_player.get_playback_position()
		_bgm_player.stop()
		Global.game_state = Global.GameState.PAUSED


func _on_ui_retried():
	# ポーズ中 or ゲームオーバー: シーンを再読み込みする
	var states = [Global.GameState.PAUSED, Global.GameState.GAMEOVER]
	if states.has(Global.game_state):
		get_tree().reload_current_scene()


func _on_hero_damged():
	# ゲーム中でない: ダメージを受けても何も起きない
	if Global.game_state != Global.GameState.ACTIVE:
		return

	Global.life -= 1

	# Hero の残機が 0 になった場合: ゲームオーバー
	if Global.life == 0:
		Global.game_state = Global.GameState.GAMEOVER
		_play_se(GAMEOVER_SOUND)
		_enter_slow(SLOW_SPEED_GAMEOVER, SLOW_DURATION_GAMEOVER)
		print("Game is ended.")
		Global.game_ended.emit()
		return

	# まだ残機がある場合: 無敵状態に突入する
	if !Global.is_hero_anti_damage:
		_play_se(DAMAGE_SOUND)
		_enter_anti_damage()


func _on_hero_got_level():
	Global.level += LEVEL_BASE
	_gate_counter_shop += 1
	_gate_counter_difficult += 1

	# 難易度上昇の規定回数に達した場合
	if _gate_counter_difficult_quota <= _gate_counter_difficult:
		_gate_counter_difficult = 0
		_gate_gap -= GATE_GAP_STEP
		print("current gate gap: {0}".format([_gate_gap]))

	# 店生成の規定回数に達した場合
	# 店の看板で難易度を表示するので難易度の処理よりあとに書く
	if _gate_counter_shop_quota <= _gate_counter_shop:
		_gate_counter_shop = 0
		_shop_counter += 1
		_is_spawn_gate = false
		_is_spawn_enemy = false
		_spawn_shop()


func _on_hero_got_money():
	Global.money += _money_base
	_play_se(MONEY_SOUND)


func _on_hero_got_gear(gear):
	Global.money -= Gear.GEAR_INFO[gear]["c"]
	Gear.my_gears += [gear]
	_play_se(GEAR_SOUND)

	# ギアの効果を発動する
	# EME: _on_hero_kills_enemy()
	# MSB: hero._on_hero_got_gear
	match gear:
		Gear.GearTyoe.EMP:
			_enemy_spawn_height_max = 0
		Gear.GearType.EMS:
			var _ems = [2, 3, 5]
			var _ems_count = Gear.my_gears.count(Gear.GearType.EMS)
			_enemy_spawn_cooltime = ENEMY_SPAWN_COOLTIME_BASE / _ems[_ems_count]
		Gear.GearType.EXT:
			Global.extra += 5
		Gear.GearType.GTG:
			_gate_gap += 64
		Gear.GearType.LFP:
			Global.life += 1
		Gear.GearType.LFM:
			Global.life -= 1
			Global.extra *= 2
		Gear.GearType.SCL:
			Global.hero_move_velocity *= 1.25
			Global.extra *= 2


func _on_hero_entered_shop():
	if Global.game_state == Global.GameState.ACTIVE:
		_enter_slow(SLOW_SPEED_SHOP, SLOW_DURATION_SHOP)


func _on_hero_exited_shop():
	if Global.game_state == Global.GameState.ACTIVE:
		_exit_slow(SLOW_DURATION_SHOP)
		_is_spawn_gate = true
		_is_spawn_enemy = true


func _on_hero_kills_enemy():
	_play_se(DAMAGE_SOUND)

	# EME
	var _eme = [0, 1, 2, 3]
	var _eme_count = Gear.my_gears.count(Gear.GearType.EME)
	Global.extra += _eme[_eme_count]


# スロー用の Tween を取得する
func _get_slow_tween():
	if _slow_tween:
		_slow_tween.kill()

	_slow_tween = create_tween()
	_slow_tween.set_trans(Tween.TRANS_QUINT)
	_slow_tween.set_ease(Tween.EASE_OUT)
	return _slow_tween


# 通常速度からスローになっていく
func _enter_slow(speed, duration):
	var _bgm_speed = (1.0 + speed) / 2 # BGM は弱めのスロー
	var _tween = _get_slow_tween()
	_tween.set_parallel(true)	
	_tween.tween_property(Engine, "time_scale", speed, duration)
	_tween.tween_property(_bgm_player, "pitch_scale", _bgm_speed, duration)


# スローから通常速度になっていく
func _exit_slow(duration):
	var _tween = _get_slow_tween()
	_tween.set_parallel(true)
	_tween.tween_property(Engine, "time_scale", 1.0, duration)
	_tween.tween_property(_bgm_player, "pitch_scale", 1.0, duration)


# 無敵時間用の Tween を取得する
func _get_anti_damage_tween():
	if _anti_damage_tween:
		_anti_damage_tween.kill()
	_anti_damage_tween = create_tween()
	_anti_damage_tween.set_trans(Tween.TRANS_LINEAR)
	return _anti_damage_tween


# 無敵状態に突入する
func _enter_anti_damage():
	Global.is_hero_anti_damage = true

	var _tween = _get_anti_damage_tween()
	var _duration = 1.0 # TODO: 引数にする
	_hero_anti_damage_bar.visible = true
	_hero_anti_damage_bar.value = 100

	_tween.tween_property(_hero_anti_damage_bar, "value", 0, _duration)
	_tween.tween_callback(func(): _hero_anti_damage_bar.visible = false)
	_tween.tween_callback(func(): Global.is_hero_anti_damage = false)
	#_tween.tween_callback(func(): print("Anti-damage is finished."))


# ゲートを生成する
func _spawn_gate():
	var _gate = GATE_SCENE.instantiate()
	_gate.position.x += (_hero.position.x + 360)
	_gate.position.y += 320
	_gate.gap_diff = _gate_gap
	_gate.height_diff += _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	get_tree().root.get_node("Main").add_child(_gate)
	#print("Gate is spawned.")


# ゲートを生成しつづける (_process 内で呼ぶ)
func _process_spawn_gate(delta):
	if _is_spawn_gate:
		_gate_spawn_timer += delta

	if _gate_spawn_cooltime < _gate_spawn_timer:
		_spawn_gate()
		_gate_spawn_timer = 0


# 敵を生成する
func _spawn_enemy():
	var _enemy = ENEMY_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_enemy.position.x += (_hero.position.x + 360)
	_enemy.position.y += (_height_diff + 320)
	get_tree().root.get_node("Main").add_child(_enemy)
	#print("Enemy is spawned.")


# 敵を生成しつづける (_process 内で呼ぶ)
func _process_spawn_enemy(delta):
	if _is_spawn_enemy:
		_enemy_spawn_timer += delta

	if _enemy_spawn_cooltime < _enemy_spawn_timer:
		_spawn_enemy()
		_enemy_spawn_timer = 0


# 店を生成する
func _spawn_shop():
	var _shop = SHOP_SCENE.instantiate()
	_shop.position.x += (_hero.position.x + 720)
	_shop.position.y += 320
	_shop.number = _shop_counter
	_shop.gate_gap = 256 + _gate_gap
	get_tree().root.get_node("Main").add_child(_shop)
	#print("Shop is spawned.")


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
