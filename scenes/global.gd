extends Node


# Signals
# 基本的に game の中で emit する
# 衝突系のみ hero の中で emit する
signal game_initialized # ゲームが初期化 + 一時停止されたとき
signal game_ended # ゲームが終了したとき
signal game_paused # ゲームが一時停止したとき
signal game_resumed # ゲームが再開されたとき
signal hero_jumped # Hero がジャンプしたとき
signal hero_got_level # Hero が Level を取ったとき (hero マター)
signal hero_got_money # Hero が Money を取ったとき (hero マター)
signal hero_damged # Hero がダメージを受けたとき (hero マター)
signal hero_dead # Hero が死んだとき

signal level_changed
signal money_changed
signal extra_changed
signal score_changed
signal life_changed


# Variables
var is_game_active = false # ゲームが進行中かどうか
var is_hero_dead = false # Hero が死んでいるかどうか

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
var life = 1: # Hero の残機
	get:
		return life
	set(value):
		life_changed.emit(value)
		life = value


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func init():
	is_game_active = false
	is_hero_dead = false
	level = 0
	money = 0
	extra = 1
	score = 0
	life = 1
