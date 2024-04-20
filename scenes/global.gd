extends Node


# Signals
signal hero_jumped # Hero がジャンプしたとき
signal hero_damged # Hero がダメージを受けたとき
signal hero_dead # Hero が死んだとき
signal hero_got_money # Coin を取ったとき

# Variables
var is_game_active = false # ゲームが進行中かどうか
var is_hero_dead = false # Hero が死んでいるかどうか
var level = 0
var money = 0
var extra = 1
var life_count = 1 # Hero の残機


# 初期化
# シーン再読み込み後に必ず呼ぶこと
func init():
	is_game_active = false
	is_hero_dead = false
	level = 0
	money = 0
	extra = 1
	life_count = 1
