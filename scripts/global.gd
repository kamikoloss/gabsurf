extends Node


signal state_changed
signal rank_changed
signal stage_changed
signal level_changed
signal money_changed
signal extra_changed
signal score_changed
signal life_changed

signal ui_jumped # ジャンプボタンを押したとき
signal ui_paused # ポーズボタンを押したとき
signal ui_retried # リトライボタンを押したとき

signal hero_got_level # Level に触れたとき
signal hero_got_money # Money に触れたとき
signal hero_touched_gear # Gear に触れたとき (まだ取得していない)
signal hero_got_gear # Gear を取得したとき
signal hero_damaged # ダメージを受けたとき
signal hero_entered_shop # Shop に入ったとき
signal hero_exited_shop # Shop を出たとき

signal enemy_dead # 倒されたとき


enum State {
	NONE, # 初期値
	TITLE, # タイトル
	ACTIVE, # ゲーム中
	PAUSED, # ポーズ中
	GAMEOVER, # ゲームオーバー
}

enum Rank {
	NONE, # 初期値
	WHITE,
	BLUE,
	GREEN,
	RED,
	GOLD,
}

enum Stage {
	NONE, # 初期値
	A,
	B,
	C,
	D,
	E,
	F,
}


const MONEY_RATIO = 5 # Money の係数
const LIFE_MAX = 3 # Life の最大数
const HERO_MOVE_VELOCITY_DEFAULT = 200 # Hero の移動速度のデフォルト値 (px/s)
const GATE_GAP_BASE = 256 # Gate の開きのデフォルト値 (px)


var state: State = State.NONE:
	get:
		return state
	set(value):
		if value == state:
			return
		var _from = state
		state = value
		print("[Global] state is changed. ({0} -> {1})".format([_from, value]))
		state_changed.emit(_from)

var rank: Rank = Rank.NONE:
	get:
		return rank
	set(value):
		if value == rank:
			return
		var _from = rank
		rank = value
		print("[Global] rank is changed. ({0} -> {1})".format([_from, value]))
		rank_changed.emit(_from)

var stage: Stage = Stage.NONE:
	get:
		return stage
	set(value):
		if value == stage:
			return
		var _from = stage
		stage = value
		print("[Global] stage is changed. ({0} -> {1})".format([_from, value]))
		stage_changed.emit(_from)

var level: int = -1:
	get:
		return level
	set(value):
		if value == level:
			return
		var _from = level
		level = value
		#print("[Global] level is changed. ({0} -> {1})".format([_from, value]))
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
		#print("[Global] money is changed. ({0} -> {1})".format([_from, value]))
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
		#print("[Global] extra is changed. ({0} -> {1})".format([_from, value]))
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
		print("[Global] score is changed. ({0} -> {1})".format([_from, value]))
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
		print("[Global] life is changed. ({0} -> {1})".format([_from, value]))
		life_changed.emit(_from)


var can_hero_jump: bool = true # Hero がジャンプできるかどうか キーボード操作のときだけ確認する
var is_hero_anti_damage: bool = false # Hero が無敵状態かどうか
var hero_move_velocity: int = HERO_MOVE_VELOCITY_DEFAULT # Hero の横移動の速度 (px/s)
var gate_gap_diff: int = 0 # Gate の開きの差 (px) マイナスで狭くなる
var shop_through_count: int = 0 # Shop を連続何回スルーしたか

var _accelerate_tween = null


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	state = State.TITLE
	rank = Rank.WHITE
	stage = Stage.A
	level = 0
	money = 0
	extra = 1
	score = 0
	life = LIFE_MAX

	can_hero_jump = true
	is_hero_anti_damage = false
	hero_move_velocity = HERO_MOVE_VELOCITY_DEFAULT
	gate_gap_diff = 0
	shop_through_count = 0


# 現在の GameRank を計算する
func _calc_game_rank():
	if score < 1_000:
		return Rank.WHITE
	elif 1_000 <= score and score < 10_000:
		return Rank.BLUE
	elif 10_000 <= score and score < 100_000:
		return Rank.GREEN
	elif 100_000 <= score and score < 1_000_000:
		return Rank.RED
	else:
		return Rank.GOLD


# 現在の Score を計算する
func _calc_score():
	if level == null or money == null or extra == null:
		return

	return level * money * extra


# Hero の横移動の速度を一時的に加速する
func accelerate_hero_move(speed_diff, duration):
	var _from = HERO_MOVE_VELOCITY_DEFAULT + speed_diff
	var _to = HERO_MOVE_VELOCITY_DEFAULT

	if _accelerate_tween:
		_accelerate_tween.kill()
	_accelerate_tween = create_tween()
	_accelerate_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	_accelerate_tween.tween_method(func(v): hero_move_velocity = v, _from, _to, duration)
