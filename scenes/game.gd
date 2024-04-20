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
var _gate_spawn_cooltime = 3 # 何秒ごとに壁が出現するか
var _rng = RandomNumberGenerator.new() # 乱数生成


func _ready():
	# Signal 接続
	Global.hero_damged.connect(_on_hero_damged)
	Global.hero_dead.connect(_on_hero_dead)

	# ゲーム初期化
	_reset_game()


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


# ゲームを初期化 + 一時停止する
# _resume_game() で開始する
func _reset_game():
	print("Waiting start...")
	Engine.time_scale = 1.0
	set_process(false)
	set_physics_process(false)
	Global.is_game_active = false
	Global.is_hero_dead = false
	_loop_spawn_gate()


# ゲームを終了する
func _end_game():
	print("Game is end!")
	Global.is_game_active = false


# ゲームを一時停止する
func _pause_game():
	if (!Global.is_game_active or Global.is_hero_dead):
		return
	print("Game is paused.")
	Engine.time_scale = 0.0
	set_process(false)
	set_physics_process(false)
	Global.is_game_active = false


# ゲームを再開する
func _resume_game():
	if (Global.is_game_active or Global.is_hero_dead):
		return
	print("Game is resumed.")
	Engine.time_scale = 1.0
	set_process(true)
	set_physics_process(true)
	Global.is_game_active = true


# ポーズボタンが押されたとき
func _on_pause_button_down():
	_pause_game()


# ジャンプボタンが押されたとき
func _on_jump_button_down():
	_resume_game()
	Global.hero_jumped.emit()


# Hero がダメージを受けたとき
func _on_hero_damged():
	print("Hero is damged!")
	Global.life_count -= 1
	# 残りライフが0になった場合: 死ぬ
	if (Global.life_count == 0):
		Global.hero_dead.emit()


# Hero が死んだとき
func _on_hero_dead():
	print("Hero is dead!")
	Global.is_hero_dead = true
	_end_game()


# ゲートを出現させる
func _spawn_gate():
	print("Gate is spawned.")
	var _new_gate = GATE_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_new_gate.position.x += (_hero.position.x + 360)
	_new_gate.position.y +=  _height_diff
	get_tree().root.get_node("Main").add_child(_new_gate)
	return _new_gate


# ゲートを出現させつづける
func _loop_spawn_gate():
	# Hero が死んだらループを中止する
	if (Global.is_hero_dead):
		print("Stop spawn gate loop.")
		return

	if (Global.is_game_active):
		_spawn_gate()

	await get_tree().create_timer(_gate_spawn_cooltime).timeout
	_loop_spawn_gate() # 次のループへ
