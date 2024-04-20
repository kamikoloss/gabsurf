extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

# Resources
# TODO

# Nodes
@onready var _hero = $Hero
@onready var _walls = $Walls

# Constants
const SLOW_SPEED = 0.25 # スロー状態で何倍速になるか
const SLOW_DURATION = 1.0 # スロー状態に何秒かけて移行するか
const GATE_HEIGHT_MIN = -80 # (px)
const GATE_HEIGHT_MAX = 80 # (px) 

# Variables
var _slow_tween = null
var _gate_spawn_cooltime = 2.0 # 何秒ごとにゲートを生成するか
var _enemy_spawn_cooltime = 3.0 # 何秒ごとに敵を生成するか
var _rng = RandomNumberGenerator.new() # 乱数生成


func _ready():
	# Signal 接続
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.ui_paused.connect(_on_ui_paused)
	Global.ui_retried.connect(_on_ui_retried)
	Global.hero_damged.connect(_on_hero_damged)
	Global.hero_got_level.connect(_on_hero_got_level)
	Global.hero_got_money.connect(_on_hero_got_money)

	# 初期化
	_initialize_game()


func _process(delta):
	# Walls を Hero に追随させる
	if (_hero != null):
		_walls.position.x = _hero.position.x


# ゲームを初期化 + 一時停止する
func _initialize_game():
	print("Waiting start...")
	Engine.time_scale = 1.0
	set_process(false)
	set_physics_process(false)
	Global.initialize()
	Global.game_initialized.emit()


	# ゲートおよび敵の生成開始
	# Global.init() のあとに呼ぶこと
	_loop_spawn_gate()
	_loop_spawn_enemy()


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
		_enter_slow()
		print("Game is ended.")
		Global.game_ended.emit()


func _on_hero_got_level():
	Global.level += 10
	Global.score = _calc_score()


func _on_hero_got_money():
	Global.money += 1
	Global.score = _calc_score()


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
func _enter_slow():
	_get_slow_tween().tween_property(Engine, "time_scale", SLOW_SPEED, SLOW_DURATION)


# スローから通常速度になっていく
func _leave_slow():
	_get_slow_tween().tween_property(Engine, "time_scale", 1.0, SLOW_DURATION)


# ゲートを生成する
func _spawn_gate():
	print("Gate is spawned.")
	var _gate = GATE_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_gate.position.x += (_hero.position.x + 360)
	_gate.position.y += _height_diff
	get_tree().root.get_node("Main").add_child(_gate)


# ゲートを生成しつづける
# TODO: pause 対応 (await じゃなくてループ内でやる？)
func _loop_spawn_gate():
	# ゲームオーバー: ループを中止する
	if (Global.game_state == Global.GameState.GAMEOVER):
		print("Stop spawn gate loop.")
		return

	# ゲーム中: ゲートを生成する
	if (Global.game_state == Global.GameState.ACTIVE):
		_spawn_gate()

	# 一定時間待ったあと次のループに移行する
	await get_tree().create_timer(_gate_spawn_cooltime).timeout
	_loop_spawn_gate()


# 敵を生成する
func _spawn_enemy():
	print("Enemy is spawned.")
	var _enemy = ENEMY_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_enemy.position.x += (_hero.position.x + 360)
	_enemy.position.y += (_height_diff + 320)
	get_tree().root.get_node("Main").add_child(_enemy)


# 敵を生成しつづける
# TODO: pause 対応 (await じゃなくてループ内でやる？)
func _loop_spawn_enemy():
	# ゲームオーバー: ループを中止する
	if (Global.game_state == Global.GameState.GAMEOVER):
		print("Stop spawn enemy loop.")
		return

	# ゲーム中: 敵を生成する
	if (Global.game_state == Global.GameState.ACTIVE):
		_spawn_enemy()

	# 一定時間待ったあと次のループに移行する
	await get_tree().create_timer(_enemy_spawn_cooltime).timeout
	_loop_spawn_enemy()
