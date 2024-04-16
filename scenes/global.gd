extends Node

# ゲームが一時停止されたとき
signal game_paused
# ゲームが再開されたとき
signal game_resumed
# ジャンプしたとき
signal jumped


# ゲームが進行中かどうか
var is_game_active = false:
	get:
		return is_game_active
	set(value):
		is_game_active = value
		if (is_game_active):
			game_resumed.emit()
			print("Game resumed.")
		else:
			game_paused.emit()
			print("Game paused.")
