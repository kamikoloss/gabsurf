extends Node


# Signals
# Game: 初期化およびロジックの結果
signal game_initialized # ゲームが初期化されたとき
signal game_ended # ゲームが終了したとき

# UI: 入力系
signal ui_jumped # ジャンプボタンを押したとき
signal ui_paused # ポーズボタンを押したとき
signal ui_retried # リトライボタンを押したとき

# Hero: Hero の衝突
signal hero_got_level # Level を取ったとき
signal hero_got_money # Money を取ったとき
signal hero_damged # ダメージを受けたとき

# Global: 値の変更
signal level_changed
signal money_changed
signal extra_changed
signal score_changed
signal life_changed


# ゲームの状態
enum GameState {
	TITLE, # タイトル
	PAUSED, # ポーズ中
	ACTIVE, # ゲーム中
	GAMEOVER, # ゲームオーバー
}


# Variables
var game_state = GameState.TITLE

var level = 0:
	get:
		return level
	set(value):
		level_changed.emit(value)
		level = value
var money = 0:
	get:
		return money
	set(value):
		money_changed.emit(value)
		money = value
var extra = 1:
	get:
		return extra
	set(value):
		extra_changed.emit(value)
		extra = value
var score = 0:
	get:
		return score
	set(value):
		score_changed.emit(value)
		score = value
var life = 1:
	get:
		return life
	set(value):
		life_changed.emit(value)
		life = value


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	game_state = GameState.TITLE
	level = 0
	money = 0
	extra = 1
	score = 0
	life = 1
