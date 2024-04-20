extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")

# Resources
# TODO

# Constants
const GATE_HEIGHT_MIN = -80 # (px)
const GATE_HEIGHT_MAX = 80 # (px) 
const GATE_INITIAL_X = 400 # (px)

# Variables
var gate_spawn_cooltime = 3 # 何秒ごとに壁が出現するか
var gate_gap = 1 # ゲートの開き具合の (デフォルト値)
var gate_speed = 200 # ゲートが迫ってくる速さ (デフォルト値)

var _rng = RandomNumberGenerator.new() # 乱数生成

# Nodes
@onready var _wall_top = $WallTop
@onready var _wall_bottom = $WallBottom
@onready var _gates = $Gates


func _ready():
	# Group 設定
	_wall_top.add_to_group("Wall")
	_wall_bottom.add_to_group("Wall")
	# Signal 接続
	Global.hero_damged.connect(_on_hero_damged)
	Global.hero_dead.connect(_on_hero_dead)
	# ゲーム初期化
	_reset_game()


func _process(delta):
	if (Global.is_hero_dead):
		# 徐々にスローになる
		if (0.25 < Engine.time_scale):
			Engine.time_scale *= 0.95


# 入力制御
func _input(event):
	if event is InputEventKey:
		# キーが押されたとき
		if event.pressed:
			match event.keycode:
				KEY_SPACE:
					_on_jump_button_down()
				KEY_ESCAPE:
					_on_pause_button_down()
		# キーが離されたとき
		else:
			pass


# ゲームを初期化 + 一時停止する
# _resume_game() で開始する
func _reset_game():
	print("Waiting start...")
	Engine.time_scale = 1.0
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)
	_loop_spawn_gate()


# ゲームを終了する
func _end_game():
	print("Game is end!")
	Global.is_game_active = false


# ゲームを一時停止する
func _pause_game():
	if (!Global.is_game_active):
		return
	print("Game is paused.")
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)


# ゲームを再開する
func _resume_game():
	if (Global.is_game_active):
		return
	print("Game is resumed.")
	Global.is_game_active = true
	set_process(true)
	set_physics_process(true)


# ポーズボタンが押されたとき
func _on_pause_button_down():
	if (Global.is_game_active):
		_pause_game()
	else:
		_resume_game()


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
	var _new_gate = GATE_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_new_gate.scale /= _gates.scale
	_new_gate.position.x += GATE_INITIAL_X
	_new_gate.position.y += _height_diff
	_gates.add_child(_new_gate)
	return _new_gate


# ゲートを出現させつづける
func _loop_spawn_gate():
	# Hero が死んだらループを中止する
	if (Global.is_hero_dead):
		print("Stop spawn gate loop.")
		return

	if (Global.is_game_active):
		_spawn_gate()
	await get_tree().create_timer(gate_spawn_cooltime).timeout
	_loop_spawn_gate() # 次のループへ
