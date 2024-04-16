extends Node2D


func _ready():
	_start_game()


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
	set_process(false)
	set_physics_process(false)


# ゲームを一時停止する
func _pause_game():
	Global.is_game_active = false
	set_process(false)
	set_physics_process(false)


# ゲームを再開する
func _resume_game():
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
	Global.jumped.emit()
