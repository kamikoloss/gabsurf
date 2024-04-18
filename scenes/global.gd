extends Node


# Hero がジャンプしたとき
signal hero_jumped
# Hero がダメージを受けたとき
signal hero_damged
# Hero が死んだとき
signal hero_dead


# ゲームが進行中かどうか
var is_game_active = false
# Hero の残機
var life_count = 1
# Hero が死んでいるかどうか
var is_hero_dead = false
