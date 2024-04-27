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
const GEARS_ON_SALE_DEFAULT = [ 
	#GearType.DEC,
	#GearType.EXT,
	#GearType.JET,
	#GearType.KIL,
	#GearType.LIF,
	#GearType.MIS,
	GearType.SHO,
]

# Variables
var gears_on_sale = [] # 店に並ぶギアのリスト
var my_gears = [] # 所持しているギアのリスト


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	gears_on_sale = GEARS_ON_SALE_DEFAULT
	my_gears = []


# ランダムなギアを取得する
# 抽選に失敗した場合は null を返す
func get_random_gear(_ignore_gear = null):
	var _gear = null

	for n in 10:
		var _random = gears_on_sale[randi() % gears_on_sale.size()]
		print(_random)
		# 避けるギアが抽選された場合: 次のループへ
		if (_random == _ignore_gear):
			continue
		# すでに持っている場合
		if Gear.my_gears.has(_random):
			# まだ持てる場合は店に並べる
			if Gear.my_gears.count(_random) < Gear.GEAR_INFO[_random]["m"]:
				_gear = _random
				break
		# まだ持っていない場合: 店に並べる
		else:
			_gear = _random

	return _gear
