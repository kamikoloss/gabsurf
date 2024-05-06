extends Node


# Gear の種類
enum GearType {
	ATD, BDA, COL,
	EME, EMP, EMS, # Enemy 系
	EXT,
	GTG, GTM, # Gate 系
	LFP, LFM, # Life 系
	LOT,
	MSB, MSM, MSW, # ミサイル系
	NOE, NOS, # 出現しなくなる系
	SCL, SHO,
	SPR, SPT, # Shop 系
}


# Gear の情報
# "c": コスト, "m": 最大何個買えるか, "i": ITEM_SPRITES の index,
# "t": 名称, "d": 説明文, "f": 説明文のフォーマット,
const GEAR_INFO = {
	GearType.ATD: { "c": 5, "m": 3, "i": 3, "t": "プロテイン", "d": "敵を倒すたびに\n{0}秒無敵になる", "f": [1, 2, 3] },
	GearType.BDA: { "c": 5, "m": 1, "i": 4, "t": "ボディーアーマー", "d": "無敵時に敵を体当たりで\n倒せるようになる", "f": null  },
	#GearType.COL: { "c": 2, "m": 1, "i": 8, "t": "デコンパイラ", "d": "すべての当たり判定が\n見えるようになる", "f": null },
	GearType.EME: { "c": 3, "m": 3, "i": 11, "t": "狩猟免許", "d": "敵を倒すたびに\nEXTRA +{0}", "f": [1, 2, 3] },
	GearType.EMP: { "c": 5, "m": 1, "i": 8, "t": "音響装置", "d": "敵が下半分にだけ\n出現するようになる", "f": null },
	GearType.EMS: { "c": 5, "m": 3, "i": 10, "t": "パンくず", "d": "敵の出現ペース\nx{0}", "f": [2, 3, 5] },
	GearType.EXT: { "c": 1, "m": 5, "i": 2, "t": "エナジーフード", "d": "EXTRA +5", "f": null },
	GearType.GTG: { "c": 5, "m": 5, "i": 8, "t": "ハックツール", "d": "ゲートの開き\n+64", "f": null },
	GearType.GTM: { "c": 3, "m": 3, "i": 1, "t": "ビール", "d": "ゲートが{0}個ずつ\n出現するようになる", "f": [2, 3, 5] },
	GearType.LFP: { "c": 5, "m": 5, "i": 12, "t": "生命保険", "d": "残機\n+1", "f": null },
	GearType.LFM: { "c": 0, "m": 3, "i": 12, "t": "臓器売買", "d": "残機 -1\nMONEY +10", "f": null },
	GearType.LOT: { "c": 2, "m": 5, "i": 5, "t": "宝くじ", "d": "MONEY +0 ~ +5", "f": null},
	GearType.MSB: { "c": 2, "m": 3, "i": 6, "t": "ミサイル", "d": "ジャンプ{0}回ごとに\nミサイルを1発発射する", "f": [5, 3, 2] },
	#GearType.MSH: { "c": 2, "m": 3, "i": 6, "t": "追尾ミサイル", "d": "ミサイルが敵を追いかける\n (追尾強度: {0})", "f": ["小", "中", "大"] }, 
	#GearType.MSM: { "c": 2, "m": 3, "i": 6, "t": "マルチミサイル", "d": "ミサイルを{0}\n方向に発射する", "f": [2, 3, 5] },
	#GearType.MSW: { "c": 2, "m": 3, "i": 6, "t": "巨大ミサイル", "d": "壁がミサイル{0}発で\n壊れるようになる", "f": [5, 3, 2] },
	GearType.NOE: { "c": 10, "m": 1, "i": 1, "t": "安全運転", "d": "敵が出現しなくなる\n EXTRA x2", "f": null},
	GearType.NOS: { "c": 10, "m": 1, "i": 1, "t": "ミニマリスト", "d": "ショップが出現しなくなる\nEXTRA x2", "f": null },
	GearType.SCL: { "c": 5, "m": 1, "i": 9, "t": "ジェットエンジン", "d": "進行速度 x1.25\nEXTRA x2", "f": null },
	GearType.SHO: { "c": 2, "m": 1, "i": 7, "t": "安全靴", "d": "敵を踏んで\n倒せるようになる", "f": null },
	GearType.SPR: { "c": 5, "m": 1, "i": 12, "t": "買い物袋", "d": "ショップをスルーすると\n1度だけショップが\n再出現する", "f": null },
	GearType.SPT: { "c": 5, "m": 1, "i": 12, "t": "貯金箱", "d": "ショップをn連続\nスルーするごとに\nMONEY +n", "f": null },
}

# ランクごとに店に並ぶギアのリスト
const GEAR_RANK = {
	Global.Rank.WHITE: [
		GearType.EME,
		GearType.EXT,
		GearType.MSB,
		GearType.SHO,
	],
	Global.Rank.BLUE: [
		GearType.ATD,
		GearType.EMP,
		GearType.GTM,
		GearType.LOT,
		GearType.SPR,
		GearType.SPT,
	],
	Global.Rank.GREEN: [
		GearType.EMS,
		GearType.GTG,
		GearType.LFP,
		GearType.SCL,
	],
	Global.Rank.RED: [
		GearType.BDA,
		GearType.LFM,
	],
	Global.Rank.GOLD: [
		GearType.NOE,
		GearType.NOS,
	],
}

# ギアの画像
const ITEM_SPRITES = [
	preload("res://images/circle.png"), # Debug
	preload("res://images/item1.png"),
	preload("res://images/item2.png"),
	preload("res://images/item3.png"),
	preload("res://images/item4.png"),
	preload("res://images/item5.png"),
	preload("res://images/item6.png"),
	preload("res://images/item7.png"),
	preload("res://images/item8.png"),
	preload("res://images/item9.png"),
	preload("res://images/item10.png"),
	preload("res://images/item11.png"),
	preload("res://images/item12.png"),
]


# Variables
var my_gears: Array[GearType] = [] # 所持しているギアのリスト


# グローバル変数の初期化を行う
# シーン読み込み後に必ず呼ぶこと
func initialize():
	my_gears = []
	#my_gears = [GearType.ATD, GearType.ATD, GearType.ATD, GearType.BDA, GearType.SHO, GearType.NOS] # 無敵ループデバッグ
	#my_gears = [GearType.NOE, GearType.NOS] # 出現しなくなるデバッグ
	my_gears = [GearType.SPR, GearType.SPT]


# ランダムな Gear を取得する
# 抽選に失敗した場合は null を返す
func get_random_gear(ignore = null):
	var _gear = null # 最終的に取得される Gear
	var _gears_on_sale = [] # 店頭に並ぶ Gear

	# 現在のランクまでの Gear を店頭に並べる
	for r in Global.Rank.values():
		if r != Global.Rank.NONE and r <= Global.rank:
			_gears_on_sale += GEAR_RANK[r]

	# 特殊条件
	# 現在の残機が最大数の場合: LFP は並べない
	if Global.life == Global.LIFE_MAX and _gears_on_sale.has(GearType.LFP):
		_gears_on_sale.remove_at(_gears_on_sale.find(GearType.LFP))

	# Gear を抽選する
	for n in 10:
		# 店頭に並んでいる Gear が存在しない場合: 中止
		if _gears_on_sale.size() == 0:
			break
		# 抽選する
		var _random = _gears_on_sale[randi() % _gears_on_sale.size()]
		# 避ける Gear が抽選された場合: NG 次のループへ
		if _random == ignore:
			continue
		# すでに持っている Gear が抽選された場合
		if my_gears.has(_random):
			# まだ最大数に達していない場合: OK
			if 0 < GEAR_INFO[_random]["m"] and my_gears.count(_random) < GEAR_INFO[_random]["m"]:
				_gear = _random
				break
		# まだ持っていない場合: OK
		else:
			_gear = _random
			break

	return _gear


# Shop UI 用の Gear 情報を取得する
func get_gear_ui(gear):
	var _gear_info = GEAR_INFO[gear]
	var _title = ""
	var _desc = ""
	var _max = ""

	# 名称をランクの色にする
	var _rank_color = null
	for key in GEAR_RANK:
		if GEAR_RANK[key].has(gear):
			_rank_color = key
	match _rank_color:
		Global.Rank.WHITE:
			_title = _gear_info["t"]
		Global.Rank.BLUE:
			_title = "[color=blue]{0}[/color]".format([_gear_info["t"]])
		Global.Rank.GREEN:
			_title = "[color=green]{0}[/color]".format([_gear_info["t"]])
		Global.Rank.RED:
			_title = "[color=red]{0}[/color]".format([_gear_info["t"]])
		Global.Rank.GOLD:
			_title = "[color=yellow]{0}[/color]".format([_gear_info["t"]])

	# 説明文を必要に応じてフォーマットする
	if _gear_info["f"] != null:
		var _format = _gear_info["f"][my_gears.count(gear)]
		_desc = _gear_info["d"].format([_format])
	else:
		_desc = _gear_info["d"]

	# "<買ったら何個目になるか>/<最大何個買えるか>"
	var _count = my_gears.count(gear)
	_max = "{0}/{1}".format([_count + 1, _gear_info["m"]])

	return {
		"title": _title,
		"desc": _desc,
		"cost": "$" + str(_gear_info["c"]),
		"max": _max,
		"icon": ITEM_SPRITES[_gear_info["i"]],
	}
