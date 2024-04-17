extends Node2D


# Node
var _wall_top = null
var _wall_bottom = null


func _ready():
	# Node 取得
	_wall_top = $WallTop
	_wall_bottom = $WallBottom
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
	pass


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
	Global.is_game_active = true
	set_process(true)
	print("Game is started!")


# ゲームを終了する
func _end_game():
	Global.is_game_active = false
	print("Game is end!")


# ゲームの開始を待つ (ゲーム開始時のみの一時停止状態)
func _wait_start_game():
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)
	print("Waiting start...")


# ゲームを一時停止する
func _pause_game():
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)
	print("Game is paused.")


# ゲームを再開する
func _resume_game():
	Global.is_game_active = true
	set_process(true)
	set_physics_process(true)
	print("Game is resumed.")


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
func _on_hero_damged(remaining_life_count):
	print("Hero damged! remaining: {0}".format([remaining_life_count]))
	# 残りライフが0になった場合: 死ぬ
	if (remaining_life_count == 0):
		Global.hero_dead.emit()


# Hero が死んだとき
func _on_hero_dead():
	print("Hero dead!")
	_end_game()
