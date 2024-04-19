extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")

# Resources
# TODO

# Variables
var gate_spawn_cooltime = 3.0 # 何秒ごとに壁が出現するか
var gate_gap_ratio = 1 # ゲートの開き具合のデフォルト値
var gate_speed = 200 # ゲートが迫ってくる速さのデフォルト値

# Nodes
@onready var _wall_top = $WallTop
@onready var _wall_bottom = $WallBottom


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
	_spawn_gate_loop()
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)


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


# ゲートを出現させつづける
func _spawn_gate_loop():
	# Hero が死んだらループを中止する
	if (Global.is_hero_dead):
		return
	if (Global.is_game_active):
		_spawn_gate()
	await get_tree().create_timer(gate_spawn_cooltime).timeout
	_spawn_gate_loop() # 次のループへ


# ゲートを出現させる
# TODO: 画面外出たら削除する
func _spawn_gate():
	var _gate = GATE_SCENE.instantiate()
	get_tree().root.get_node("Main/Game/Gates").add_child(_gate)
	return _gate
