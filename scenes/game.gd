extends Node2D


var _is_game_active = false # ゲームが進行中か


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
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

# ジャンプする
func _jump():
	pass


# ゲームを開始する (リセット処理も含む)
func _start_game():
	_is_game_active = true
	set_process(true)
	print("Game is started!")


# ゲームを終了する
func _end_game():
	_is_game_active = false
	set_process(false)


# ゲームを一時停止する
func _pause_game():
	_is_game_active = false
	set_process(false)


# ゲームを再開する
func _resume_game():
	_is_game_active = true
	set_process(true)


# ポーズボタンが押されたときの処理
func _on_pause_button_down():
	pass # Replace with function body.


# ジャンプボタンが押されたときの処理
func _on_jump_button_down():
	pass # Replace with function body.
