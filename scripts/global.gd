extends Node


signal state_changed
signal rank_changed
signal stage_changed
signal level_changed
signal money_changed
signal extra_changed
signal score_changed

signal ui_jumped # ジャンプボタンを押したとき
signal ui_paused # ポーズボタンを押したとき
signal ui_retried # リトライボタンを押したとき

signal hero_got_level # Level を取得したとき
signal hero_got_money # Money を取得したとき
signal hero_got_gear # Gear を取得したとき
signal hero_touched_damage # ダメージに触れたとき (まだ受けていない)
signal hero_got_damage # ダメージを受けたとき
signal hero_entered_shop # Shop に入ったとき
signal hero_exited_shop # Shop を出たとき

signal enemy_dead # 倒されたとき


enum State {
	NONE,
	TITLE, # タイトル
	ACTIVE, # ゲーム中
	PAUSED, # ポーズ中
	GAMEOVER, # ゲームオーバー
}

enum Rank {
	NONE,
	WHITE,
	BLUE,
	GREEN,
	RED,
	GOLD,
	BLACK,
}

enum GearType {
	NONE,
	ATD, BDA, COL,
	EME, EMP, EMS, # Enemy 系
	EXT,
	GTG, GTM, # Gate 系
	JMA, JMV, # ジャンプ系
	LFP, LFM, # Life 系
	LOT,
	MSB, MSM, MSW, # ミサイル系
	NOE, NOS, # 出現しなくなる系
	SCL, SHO,
	SPR, SPT, # Shop 系
}

enum StageType {
	NONE,
	A,
	B,
	C,
	D,
	E,
	X,
}

enum ShopType { NONE, GEAR, STAGE }


const VERSION = "v0.6.0" # ゲームのバージョン
const MONEY_RATIO = 5 # Money の係数
const LIFE_MAX = 3 # Life の最大数

const STAGE_TARGET_RANK = { # Stage ごとの目標 Rank
	1: Global.Rank.BLUE,
	2: Global.Rank.GREEN,
	3: Global.Rank.RED,
	#1: Global.Rank.GREEN,
	#2: Global.Rank.RED,
	#3: Global.Rank.GOLD,
}


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

var stage: StageType = StageType.NONE:
	get:
		return stage
	set(value):
		if value == stage:
			return
		var _from = stage
		stage = value
		print("[Global] stage is changed. ({0} -> {1})".format([_from, value]))
		stage_changed.emit(_from)
var stage_number: int = -1

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
		#print("[Global] score is changed. ({0} -> {1})".format([_from, value]))
		score_changed.emit(_from)
		rank = _calc_rank()

var life: int = -1
var can_hero_jump: bool = true # Hero がジャンプできるかどうか キーボード操作のときだけ確認する
var gears: Array[GearType] = [] # 所持している Gear のリスト

var shop_through_count: int = 0 # Shop を連続何回スルーしたか


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	state = State.TITLE
	rank = Rank.WHITE
	stage = StageType.A
	stage_number = 1
	level = 0
	money = 0
	extra = 1
	score = 0

	life = LIFE_MAX
	can_hero_jump = true
	gears = []
	shop_through_count = 0


# 現在の Rank を計算する
func _calc_rank():
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
