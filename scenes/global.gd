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

signal state_changed
signal rank_changed
signal level_changed
signal money_changed
signal extra_changed
signal score_changed
signal life_changed


# Enums
enum State {
	TITLE, # タイトル
	PAUSED, # ポーズ中
	ACTIVE, # ゲーム中
	GAMEOVER, # ゲームオーバー
}

enum Rank {
	WHITE,
	BLUE,
	GREEN,
	RED,
	GOLD,
}


# Variables
var is_hero_anti_damage = false # 無敵状態かどうか
var hero_move_velocity = 200 # Hero の横移動の速度 (px/s)

var state = null:
	get:
		return state
	set(value):
		if value == state:
			return
		var _from = state
		state = value
		print("state is changed. ({0} -> {1})".format([_from, value]))
		state_changed.emit(_from)
var rank = null:
	get:
		return rank
	set(value):
		if value == rank:
			return
		var _from = rank
		rank = value
		print("rank is changed. ({0} -> {1})".format([_from, value]))
		rank_changed.emit(_from)

var level: int = -1:
	get:
		return level
	set(value):
		if value == level:
			return
		var _from = level
		level = value
		#print("level is changed. ({0} -> {1})".format([_from, value]))
		level_changed.emit(_from)
		score = _calc_score()
var money: int = -1:
	get:
		return money
	set(value):
		if value == money:
			return
		var _from = money
		money = value
		#print("money is changed. ({0} -> {1})".format([_from, value]))
		money_changed.emit(_from)
		score = _calc_score()
var extra: int = -1:
	get:
		return extra
	set(value):
		if value == extra:
			return
		var _from = extra
		extra = value
		#print("extra is changed. ({0} -> {1})".format([_from, value]))
		extra_changed.emit(_from)
		score = _calc_score()
var score: int = -1:
	get:
		return score
	set(value):
		if value == score:
			return
		var _from = score
		score = value
		#print("score is changed. ({0} -> {1})".format([_from, value]))
		score_changed.emit(_from)
		rank = _calc_game_rank()
var life: int = -1:
	get:
		return life
	set(value):
		if value == life:
			return
		var _from = life
		life = value
		print("life is changed. ({0} -> {1})".format([_from, value]))
		life_changed.emit(_from)


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	is_hero_anti_damage = false
	hero_move_velocity = 200

	state = State.TITLE
	rank = Rank.WHITE
	level = 0
	money = 0
	extra = 1
	score = 0
	life = 1


# 現在の Score を計算する
func _calc_score():
	if level == null or money == null or extra == null:
		return

	return level * money * extra


# 現在の GameRank を計算する
func _calc_game_rank():
	if score < 1000:
		return Rank.WHITE
	elif 1000 < score and score < 10000:
		return Rank.BLUE
	elif 10000 < score and score < 100000:
		return Rank.GREEN
	elif 100000 < score and score < 1000000:
		return Rank.RED
	elif score < 1000000:
		return Rank.GOLD
