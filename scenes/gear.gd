extends Node


# ギアの種類
enum GearType {
	ATK, DEC, EXT, GAT,
	JET, KIL, LIF,
	MIS, MSM, MSW
}


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


# ギアの情報
# "c": コスト, "m": 最大何個買えるか (0 は制限なし), "i": ITEM_SPRITES の index,
# "t": 名称, "d": 説明文, "f": 説明文のフォーマット,
const GEAR_INFO = {
	GearType.ATK: { "c": 2, "m": 1, "i": 7, "t": "安全靴", "d": "敵を踏んで倒せるようになる", "f": null },
	GearType.DEC: { "c": 2, "m": 1, "i": 1, "t": "デコンパイラ", "d": "すべての当たり判定が\n見えるようになる", "f": null },
	GearType.EXT: { "c": 3, "m": 0, "i": 2, "t": "エナジーフード", "d": "EXTRA +5", "f": null },
	GearType.GAT: { "c": 3, "m": 3, "i": 1, "t": "自撮りドローン", "d": "ゲートが{0}個ずつ\n出てくるようになる", "f": [2, 3, 5]},
	GearType.JET: { "c": 5, "m": 1, "i": 7, "t": "ジェットエンジン", "d": "進行速度 x1.25\nEXTRA x2", "f": null },
	GearType.KIL: { "c": 3, "m": 3, "i": 6, "t": "狩猟免許", "d": "敵を倒すたびに\nEXTRA +{0}", "f": [2, 3, 5] },
	GearType.LIF: { "c": 2, "m": 0, "i": 6, "t": "生命保険", "d": "残機 +1", "f": null },
	GearType.MIS: { "c": 2, "m": 3, "i": 6, "t": "ミサイル", "d": "ジャンプ{0}回ごとに\nミサイルを1発発射する", "f": [5, 3, 2],  },
	GearType.MSM: { "c": 2, "m": 3, "i": 6, "t": "マルチミサイル", "d": "ミサイルを{0}\n方向に発射する", "f": [2, 3, 5] },
	GearType.MSW: { "c": 2, "m": 3, "i": 6, "t": "超ミサイル", "d": "壁がミサイル{0}発で\n壊れるようになる", "f": [5, 3, 2] },
}

# 最初から店に並ぶギアのリストのデフォルト値
const GEARS_ON_SALE_DEFAULT = [ 
	GearType.ATK,
	#GearType.DEC,
	GearType.EXT,
	GearType.JET,
	GearType.KIL,
	GearType.LIF,
	GearType.MIS,
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
func get_random_gear(ignore = null):
	var _gear = null

	for n in 10:
		var _random = gears_on_sale[randi() % gears_on_sale.size()]

		# 避けるギアが抽選された場合: NG 次のループへ
		if (_random == ignore):
			continue

		# すでに持っている場合
		if my_gears.has(_random):
			# まだ最大数に達していない場合: OK
			if my_gears.count(_random) < GEAR_INFO[_random]["m"]:
				_gear = _random
				break
		# まだ持っていない場合: OK
		else:
			_gear = _random
			break

	return _gear


# ギア情報を取得する
func get_gear_info(gear):
	var _gear_info = GEAR_INFO[gear]
	var _desc = ""

	# 説明文を必要に応じてフォーマットする
	if _gear_info["f"] != null:
		var _format = _gear_info["f"][my_gears.count(gear)]
		_desc = _gear_info["d"].format([_format])
	else:
		_desc = _gear_info["d"]

	return {
		"c": _gear_info["c"],
		"m": _gear_info["m"],
		"i": ITEM_SPRITES[_gear_info["i"]],
		"t": _gear_info["t"],
		"d": _desc,
	}
