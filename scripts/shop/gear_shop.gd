extends Node

class_name GearShop


@export var _icons: Array[Texture]


# Gear の情報
# "c": コスト, "m": 最大何個買えるか, "i": ITEM_SPRITES の index,
# "t": 名称, "d": 説明文, "f": 説明文のフォーマット,
var _gear_info = {
	Global.GearType.ATD: { "c": 5, "m": 3, "i": 3, "t": "プロテイン", "d": "敵を倒すたびに\n{0}秒無敵になる", "f": [1, 2, 3] },
	Global.GearType.BDA: { "c": 5, "m": 1, "i": 4, "t": "ボディーアーマー", "d": "無敵時に敵を体当たりで\n倒せるようになる", "f": null },
	#Global.GearType.COL: { "c": 2, "m": 1, "i": 8, "t": "デコンパイラ", "d": "すべての当たり判定が\n見えるようになる", "f": null },
	Global.GearType.EME: { "c": 3, "m": 3, "i": 11, "t": "狩猟免許", "d": "敵を倒すたびに\nEXTRA +{0}", "f": [1, 2, 3] },
	Global.GearType.EMP: { "c": 5, "m": 1, "i": 8, "t": "音響装置", "d": "敵が下半分にだけ\n出現するようになる", "f": null },
	Global.GearType.EMS: { "c": 5, "m": 3, "i": 10, "t": "パンくず", "d": "敵の出現ペース\nx{0}", "f": [2, 3, 5] },
	Global.GearType.EXT: { "c": 1, "m": 5, "i": 2, "t": "エナジーフード", "d": "EXTRA +5", "f": null },
	Global.GearType.GTG: { "c": 5, "m": 5, "i": 8, "t": "ハックツール", "d": "ゲートの開き\n+64", "f": null },
	Global.GearType.GTM: { "c": 3, "m": 3, "i": 1, "t": "ビール", "d": "ゲートが{0}個ずつ\n出現するようになる", "f": [2, 3, 5] },
	Global.GearType.JMA: { "c": 2, "m": 3, "i": 7, "t": "ボード", "d": "ジャンプ時に\n加速する ({0})", "f": ["小", "中", "大"] },
	#Global.GearType.JMS: { "c": 3, "m": 3, "i": 7, "t": "半重力装置", "d": "ジャンプボタンを\n長押しすると\nゆっくり落下する ({0})", "f": ["小", "中", "大"] },
	Global.GearType.JMV: { "c": 2, "m": 3, "i": 7, "t": "ソフトウィール", "d": "ジャンプの高さが\n低くなる ({0})", "f": ["小", "中", "大"] },
	Global.GearType.LFP: { "c": 5, "m": 5, "i": 12, "t": "生命保険", "d": "残機\n+1", "f": null },
	Global.GearType.LFM: { "c": 0, "m": 3, "i": 12, "t": "臓器売買", "d": "残機 -1\nMONEY +{0}".format([10 * Global.MONEY_RATIO]), "f": null },
	Global.GearType.LOT: { "c": 2, "m": 5, "i": 5, "t": "宝くじ", "d": "MONEY +0 ~ +{0}".format([5 * Global.MONEY_RATIO]), "f": null},
	Global.GearType.MSB: { "c": 2, "m": 3, "i": 6, "t": "ミサイル", "d": "ジャンプ{0}回ごとに\nミサイルを1発発射する", "f": [5, 3, 2] },
	#Global.GearType.MSH: { "c": 2, "m": 3, "i": 6, "t": "追尾ミサイル", "d": "ミサイルが敵を追いかける\n (追尾強度: {0})", "f": ["小", "中", "大"] }, 
	#Global.GearType.MSM: { "c": 2, "m": 3, "i": 6, "t": "マルチミサイル", "d": "ミサイルを{0}\n方向に発射する", "f": [2, 3, 5] },
	#Global.GearType.MSW: { "c": 2, "m": 3, "i": 6, "t": "巨大ミサイル", "d": "壁がミサイル{0}発で\n壊れるようになる", "f": [5, 3, 2] },
	Global.GearType.NOE: { "c": 10, "m": 1, "i": 1, "t": "安全運転", "d": "敵が出現しなくなる\n EXTRA x2", "f": null},
	Global.GearType.NOS: { "c": 10, "m": 1, "i": 1, "t": "ミニマリスト", "d": "ショップが出現しなくなる\nEXTRA x2", "f": null },
	Global.GearType.SCL: { "c": 5, "m": 1, "i": 9, "t": "ジェットエンジン", "d": "進行速度 x1.25\nEXTRA x2", "f": null },
	Global.GearType.SHO: { "c": 2, "m": 1, "i": 7, "t": "安全靴", "d": "敵を踏んで\n倒せるようになる", "f": null },
	Global.GearType.SPR: { "c": 5, "m": 1, "i": 12, "t": "買い物袋", "d": "ショップをスルーすると\n1度だけショップが\n再出現する", "f": null },
	Global.GearType.SPT: { "c": 5, "m": 1, "i": 12, "t": "貯金箱", "d": "ショップをn連続\nスルーするごとに\nMONEY +{0}n".format([Global.MONEY_RATIO]), "f": null },
}

# Rank ごとに店に並ぶ Gear のリスト
var _gear_rank = {
	Global.Rank.WHITE: [
		Global.GearType.EME,
		Global.GearType.EXT,
		Global.GearType.MSB,
		Global.GearType.SHO,
	],
	Global.Rank.BLUE: [
		Global.GearType.ATD,
		Global.GearType.EMP,
		Global.GearType.GTM,
		Global.GearType.JMA,
		Global.GearType.JMV,
		Global.GearType.LOT,
		Global.GearType.SPR,
		Global.GearType.SPT,
	],
	Global.Rank.GREEN: [
		Global.GearType.EMS,
		Global.GearType.GTG,
		Global.GearType.LFP,
		Global.GearType.SCL,
	],
	Global.Rank.RED: [
		Global.GearType.BDA,
		Global.GearType.LFM,
	],
	Global.Rank.GOLD: [
		Global.GearType.NOE,
		Global.GearType.NOS,
	],
}


# 店頭に並ぶ可能性がある Gear を取得する
func get_active_types():
	var _active_types = []

	# 現在のランクまでの Gear を取得する
	for r in Global.Rank.values():
		if r != Global.Rank.NONE and r <= Global.rank:
			_active_types += _gear_rank[r]

	# すでに最大数持っている場合: 除く
	for g in Global.gears:
		if Global.gears.count(g) == _gear_info[g]["m"]:
			_active_types.remove_at(_active_types.find(g))

	# (GTG) ゲートが狭くならないステージの場合: 除く
	var _gate_gap_stages = [Global.StageType.B, Global.StageType.D]
	if Global.stage not in _gate_gap_stages:
		_active_types.remove_at(_active_types.find(Global.GearType.GTG))
	# (LFP) 現在の残機が最大数の場合: 除く
	if Global.life == Global.LIFE_MAX and _active_types.has(Global.GearType.LFP):
		_active_types.remove_at(_active_types.find(Global.GearType.LFP))

	return _active_types


# 表示用の情報を取得する
func get_info(type):
	var _info = _gear_info[type]
	
	var _title = ""
	var _desc = ""
	var _max = ""

	# 名称をランクの色にする
	var _rank_color = null
	for key in _gear_rank:
		if _gear_rank[key].has(type):
			_rank_color = key
	match _rank_color:
		Global.Rank.WHITE:
			_title = _info["t"]
		Global.Rank.BLUE:
			_title = "[color=#8080FF]{0}[/color]".format([_info["t"]])
		Global.Rank.GREEN:
			_title = "[color=#80FF80]{0}[/color]".format([_info["t"]])
		Global.Rank.RED:
			_title = "[color=#FF8080]{0}[/color]".format([_info["t"]])
		Global.Rank.GOLD:
			_title = "[color=#FFFF80]{0}[/color]".format([_info["t"]])

	# 説明文を必要に応じてフォーマットする
	if _info["f"] != null:
		var _format = _info["f"][Global.gears.count(type)]
		_desc = _info["d"].format([_format])
	else:
		_desc = _info["d"]

	# "<買ったら何個目になるか>/<最大何個買えるか>"
	var _count = Global.gears.count(type)
	_max = "{0}/{1}".format([_count + 1, _info["m"]])

	return {
		"title": _title,
		"desc": _desc,
		"cost": "$" + str(_info["c"] * Global.MONEY_RATIO),
		"max": _max,
		"icon": _icons[_info["i"]],
	}


func get_cost(type):
	return _gear_info[type]["c"]
