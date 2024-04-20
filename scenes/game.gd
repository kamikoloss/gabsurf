extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")

# Resources
# TODO

# Nodes
@onready var _hero = $Hero
@onready var _walls = $Walls

# Constants
const GATE_HEIGHT_MIN = -80 # (px)
const GATE_HEIGHT_MAX = 80 # (px) 

# Variables
var _gate_spawn_cooltime = 2 # 何秒ごとにゲートを生成するか
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

	# ゲート生成開始
	# Global.init() のあとに呼ぶこと
	_loop_spawn_gate()


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


# ゲートを生成する
func _spawn_gate():
	print("Gate is spawned.")
	var _new_gate = GATE_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_new_gate.position.x += (_hero.position.x + 360)
	_new_gate.position.y +=  _height_diff
	get_tree().root.get_node("Main").add_child(_new_gate)
	return _new_gate


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
