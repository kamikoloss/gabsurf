extends Node2D


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

	# ゲーム開始
	_start_game()
	_wait_start_game()


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


# ゲームを開始する (リセット処理も含む)
func _start_game():
	print("Game is started!")
	Global.is_game_active = true
	set_process(true)


# ゲームを終了する
func _end_game():
	print("Game is end!")
	Global.is_game_active = false


# ゲームの開始を待つ (ゲーム開始時のみの一時停止状態)
func _wait_start_game():
	print("Waiting start...")
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)


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
	print("Hero damged!")
	Global.life_count -= 1
	# 残りライフが0になった場合: 死ぬ
	if (Global.life_count == 0):
		Global.hero_dead.emit()


# Hero が死んだとき
func _on_hero_dead():
	print("Hero dead!")
	Global.is_hero_dead = true
	_end_game()
