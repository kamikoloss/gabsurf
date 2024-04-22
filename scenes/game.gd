extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const SHOP_SCENE = preload("res://scenes/shop.tscn")

# Resources
# TODO

# Nodes
@onready var _hero = $Hero
@onready var _walls = $Walls

# Constants
const SLOW_DURATION = 1.0 # スロー状態に何秒かけて移行するか
const SLOW_SPEED_GAMEOVER = 0.25
const SLOW_SPEED_SHOP = 0.5
const GATE_HEIGHT_MIN = -80 # (px)
const GATE_HEIGHT_MAX = 80 # (px) 

# Variables
var _level_base = 10 # ゲート通過時に Level に加算される値
var _money_base = 1 # Money 取得時に加算される値
var _shop_quota = 50 # Level がいくつ貯まるたびに Shop が出現するか
var _shop_saved = 0 # Level と同じだけ増加する Shop が出現したら 0 に戻す

var _is_spawn_gate = false # ゲートを生成するか
var _gate_spawn_cooltime = 2.0 # 何秒ごとにゲートを生成するか
var _gate_spawn_timer = 0.0
var _is_spawn_enemy = false # 敵を生成するか
var _enemy_spawn_cooltime = 3.0 # 何秒ごとに敵を生成するか
var _enemy_spawn_timer = 0.0

var _slow_tween = null
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

	_initialize_game()


func _process(delta):
	# Walls を Hero に追随させる
	if (_hero != null):
		_walls.position.x = _hero.position.x

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
	Global.game_initialized.emit()

	_is_spawn_gate = true
	_is_spawn_enemy = true


func _on_ui_jumped():
	# タイトル or ポーズ中 -> ゲーム中
	var states = [Global.GameState.TITLE, Global.GameState.PAUSED]
	if (states.has(Global.game_state)):
		Engine.time_scale = 1.0
		set_process(true)
		set_physics_process(true)
		Global.game_state = Global.GameState.ACTIVE


func _on_ui_paused():
	# ゲーム中 -> ポーズ中
	if (Global.game_state == Global.GameState.ACTIVE):
		Engine.time_scale = 0.0
		set_process(false)
		set_physics_process(false)
		Global.game_state = Global.GameState.PAUSED


func _on_ui_retried():
	# ポーズ中 or ゲームオーバー: シーンを再読み込みする
	var states = [Global.GameState.PAUSED, Global.GameState.GAMEOVER]
	if (states.has(Global.game_state)):
		get_tree().reload_current_scene()


func _on_hero_damged():
	Global.life -= 1

	# Hero の残機が 0 になった場合: ゲームオーバー
	if (Global.life == 0):
		Global.game_state = Global.GameState.GAMEOVER
		_enter_slow(SLOW_SPEED_GAMEOVER)
		print("Game is ended.")
		Global.game_ended.emit()


func _on_hero_got_level():
	Global.level += _level_base
	Global.score = _calc_score()

	# 一定 Level が貯まった場合: 店を生成する
	_shop_saved += _level_base
	if (_shop_quota <= _shop_saved):
		_spawn_shop()
		_shop_saved = 0
		# ゲートと敵の生成停止タイミング
		_is_spawn_gate = false
		_is_spawn_enemy = false


func _on_hero_got_money():
	Global.money += _money_base
	Global.score = _calc_score()


func _on_hero_entered_shop():
	if (Global.game_state != Global.GameState.ACTIVE):
		return

	_enter_slow(SLOW_SPEED_SHOP)


func _on_hero_exited_shop():
	if (Global.game_state != Global.GameState.ACTIVE):
		return

	_exit_slow()
	# ゲートと敵の生成再開タイミング
	_is_spawn_gate = true
	_is_spawn_enemy = true


func _on_hero_got_gear(gear_type):
	pass


# Score を計算する
func _calc_score():
	return Global.level * Global.money * Global.extra


# スロー用の Tween を取得する
func _get_slow_tween():
	if (_slow_tween):
		_slow_tween.kill()

	_slow_tween = create_tween()
	_slow_tween.set_trans(Tween.TRANS_QUINT)
	_slow_tween.set_ease(Tween.EASE_OUT)
	return _slow_tween


# 通常速度からスローになっていく
func _enter_slow(speed):
	_get_slow_tween().tween_property(Engine, "time_scale", speed, SLOW_DURATION)


# スローから通常速度になっていく
func _exit_slow():
	_get_slow_tween().tween_property(Engine, "time_scale", 1.0, SLOW_DURATION)


# ゲートを生成する
func _spawn_gate():
	print("Gate is spawned.")
	var _gate = GATE_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_gate.position.x += (_hero.position.x + 360)
	_gate.position.y += (_height_diff + 320)
	get_tree().root.get_node("Main").add_child(_gate)


# ゲートを生成しつづける (_process 内で呼ぶ)
func _process_spawn_gate(delta):
	if (_is_spawn_gate):
		_gate_spawn_timer += delta

	if (_gate_spawn_cooltime < _gate_spawn_timer):
		_spawn_gate()
		_gate_spawn_timer = 0


# 敵を生成する
func _spawn_enemy():
	print("Enemy is spawned.")
	var _enemy = ENEMY_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_enemy.position.x += (_hero.position.x + 360)
	_enemy.position.y += (_height_diff + 320)
	get_tree().root.get_node("Main").add_child(_enemy)


# 敵を生成しつづける (_process 内で呼ぶ)
func _process_spawn_enemy(delta):
	if (_is_spawn_enemy):
		_enemy_spawn_timer += delta

	if (_enemy_spawn_cooltime < _enemy_spawn_timer):
		_spawn_enemy()
		_enemy_spawn_timer = 0


# 店を生成する
func _spawn_shop():
	print("Shop is spawned.")
	var _shop = SHOP_SCENE.instantiate()
	_shop.position.x += (_hero.position.x + 720)
	_shop.position.y += 320
	get_tree().root.get_node("Main").add_child(_shop)
