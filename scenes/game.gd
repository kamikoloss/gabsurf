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
var _gate_spawn_cooltime = 2 # 何秒ごとに壁が出現するか
var _rng = RandomNumberGenerator.new() # 乱数生成


func _ready():
	# Signal 接続
	Global.hero_damged.connect(_on_hero_damged)
	Global.hero_dead.connect(_on_hero_dead)
	Global.hero_got_level.connect(_on_hero_got_level)
	Global.hero_got_money.connect(_on_hero_got_money)

	# 初期化
	_init_game()


func _process(delta):
	# Walls を Hero に追随させる
	if (_hero != null):
		_walls.position.x = _hero.position.x

	# Hero が死んだとき
	if (Global.is_hero_dead):
		# 徐々にスローになる
		if (0.25 < Engine.time_scale):
			Engine.time_scale *= 0.95


# キーボード入力制御
func _input(event):
	if event is InputEventKey:
		# キーボードが押されたとき
		if event.pressed:
			match event.keycode:
				KEY_SPACE:
					_on_jump_button_down()
				KEY_ESCAPE:
					_on_pause_button_down()


# ジャンプボタンが押されたとき
func _on_jump_button_down():
	_resume_game()
	Global.hero_jumped.emit()

	if (Global.is_hero_dead):
		get_tree().reload_current_scene()


# ポーズボタンが押されたとき
func _on_pause_button_down():
	_pause_game()


# ゲームを初期化 + 一時停止する
# _resume_game() で開始する
func _init_game():
	print("Waiting start...")
	Engine.time_scale = 1.0
	set_process(false)
	set_physics_process(false)
	Global.init()
	Global.game_initialized.emit()

	# ゲート生成開始
	# Global.init() のあとに呼ぶこと
	_loop_spawn_gate()


# ゲームを終了する
func _end_game():
	print("Game is end!")
	Global.is_game_active = false
	Global.game_ended.emit()


# ゲームを一時停止する
func _pause_game():
	if (!Global.is_game_active or Global.is_hero_dead):
		return
	print("Game is paused.")
	Engine.time_scale = 0.0
	set_process(false)
	set_physics_process(false)
	Global.is_game_active = false
	Global.game_paused.emit()


# ゲームを再開する
# ゲーム開始時と一時停止のあとに呼ばれる
func _resume_game():
	if (Global.is_game_active):
		return

	print("Game is resumed.")
	Engine.time_scale = 1.0
	set_process(true)
	set_physics_process(true)
	Global.is_game_active = true
	Global.game_resumed.emit()


# Hero がダメージを受けたとき
func _on_hero_damged():
	print("Hero is damged!")
	Global.life -= 1

	# Hero の残機が 0 になった場合: 死ぬ
	if (Global.life == 0):
		Global.hero_dead.emit()


# Hero が死んだとき
func _on_hero_dead():
	print("Hero is dead!")
	Global.is_hero_dead = true
	_end_game()

# Hero が Money を取ったとき
func _on_hero_got_level():
	print("Hero Got level!")
	Global.level += 10
	Global.score = _calc_score()


# Hero が Money を取ったとき
func _on_hero_got_money():
	print("Hero Got money!")
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
	# Hero が死んでいる場合: ループを中止する
	if (Global.is_hero_dead):
		print("Stop spawn gate loop.")
		return

	# ゲームが進行中の場合: ゲートを生成する
	if (Global.is_game_active):
		_spawn_gate()

	# 一定時間待ったあと次のループに移行する
	await get_tree().create_timer(_gate_spawn_cooltime).timeout
	_loop_spawn_gate()
