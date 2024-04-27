extends Node

# Resources
const ITEM_SPRITES = [
	null, # item0.png はない
	preload("res://images/item1.png"),
	preload("res://images/item2.png"),
	preload("res://images/item3.png"),
	preload("res://images/item4.png"),
	preload("res://images/item5.png"),
	preload("res://images/item6.png"),
	preload("res://images/item7.png"),
]

# ギアの種類
enum GearType {
	DEC, EXT, GAT,
	JET, KIL, LIF, MIS,
	SHO,
}

# ギアの情報
# { "t": <名称>, "d": <説明文>, "c": <コスト>, "m": 最大何個買えるか, "i": <アイコン画像の index> },
const GEAR_INFO = {
	GearType.DEC: { "t": "デコンパイラ", "d": "ガブと敵と壁の当たり判定が\n見えるようになる", "c": 3, "i": 0 },
	GearType.EXT: { "t": "エナジーフード", "d": "EXTRA +5", "c": 3, "m": null, "i": 2 },
	GearType.GAT: { "t": "自撮りドローン", "d": "ゲートが{0}個ずつ\n出てくるようになる", "m": 3, "c": 3, "i": 1 },
	GearType.JET: { "t": "ジェットエンジン", "d": "進行速度 x1.25\nEXTRA x2", "c": 3, "m": 1, "i": 7 },
	GearType.KIL: { "t": "狩猟免許", "d": "敵を倒すたびに\nEXTRA +2",  "c": 3, "m": 3, "i": 6 },
	GearType.LIF: { "t": "生命保険", "d": "残機 +1", "c": 3, "m": null, "i": 3 },
	GearType.MIS: { "t": "ミサイル", "d": "ジャンプ5回ごとに\nミサイルを1発発射する",  "m": 3, "c": 3, "i": 6, },
	GearType.SHO: { "t": "安全靴", "d": "敵を踏んで倒せるようになる", "c": 3, "m": 1, "i": 7 },
}

# 最初から店に並ぶギアのリストのデフォルト値
const GEARS_DEFAULT = [ 
	#GearType.DEC,
	#GearType.EXT,
	#GearType.JET,
	#GearType.KIL,
	GearType.LIF,
	GearType.MIS,
	GearType.SHO,
]


# Variables
var gears_on_sale = [] # 店に並ぶギアのリスト 売り切れたものは除外していく
var my_gears = [] # 所持しているギアのリスト


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	gears_on_sale = GEARS_DEFAULT
	my_gears = []


# ランダムなギアを取得する
func get_random_gear():
	return gears_on_sale[randi() % gears_on_sale.size()]
