extends Node


# Signals
signal game_initialized # ゲームが初期化されたとき
signal game_ended # ゲームが終了したとき

signal ui_jumped # ジャンプボタンを押したとき
signal ui_paused # ポーズボタンを押したとき
signal ui_retried # リトライボタンを押したとき

signal hero_damged # ダメージを受けたとき
signal hero_got_level # Level を取ったとき
signal hero_got_money # Money を取ったとき
signal hero_got_gear # Gear を取ったとき
signal hero_entered_shop # Shop に入ったとき
signal hero_exited_shop # Shop を出たとき
signal hero_kills_enemy # Enemy を倒したとき

signal level_changed
signal money_changed
signal extra_changed
signal score_changed
signal life_changed


# Enums
enum GameState {
	TITLE, # タイトル
	PAUSED, # ポーズ中
	ACTIVE, # ゲーム中
	GAMEOVER, # ゲームオーバー
}


# Variables
var game_state = GameState.TITLE
var is_hero_anti_damage = false # 無敵状態かどうか
var hero_move_velocity = 200 # Hero の横移動の速度 (px/s)

var level = 0:
	get:
		return level
	set(value):
		var _from = level
		level = value
		level_changed.emit(_from)
		score = _calc_score()
var money = 0:
	get:
		return money
	set(value):
		var _from = money
		money = value
		money_changed.emit(_from)
		score = _calc_score()
var extra = 1:
	get:
		return extra
	set(value):
		var _from = extra
		extra = value
		extra_changed.emit(_from)
		score = _calc_score()
var score = 0:
	get:
		return score
	set(value):
		var _from = score
		score = value
		score_changed.emit(_from)
var life = 1:
	get:
		return life
	set(value):
		var _from = life
		life = value
		life_changed.emit(_from)


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	game_state = GameState.TITLE
	is_hero_anti_damage = false
	hero_move_velocity = 200

	level = 0
	money = 0
	extra = 1
	score = 0
	life = 1


# Score を計算する
func _calc_score():
	return level * money * extra
