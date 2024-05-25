extends Node

class_name StageShop


# Stage の情報
# "g": Gate 1枚で LEVEL がいくつ増えるか
# "t": 名称, "d": 説明文メイン
var _stage_info = {
	# Stage 1
	Global.StageType.A: { "g": 1, "t": "ビル街", "d1": ""},
	# Stage 2
	Global.StageType.B: { "g": 3, "t": "B", "d": "ショップを通過するごとに\nゲートの狭さ -8" },
	Global.StageType.C: { "g": 2, "t": "C", "d": "ゲートが上下に動く\n (速度: 低)" },
	# Stage 3
	Global.StageType.D: { "g": 5, "t": "D", "d": "ショップを通過するごとに\nゲートの狭さ -16" },
	Global.StageType.E: { "g": 3, "t": "E", "d": "" },
	# Stage X
	Global.StageType.X: { "g": 5, "t": "成層圏", "d": "重力 1/2"},
}

# Stage Number ごとに店に並ぶ Stage のリスト
var _stage_rank = {
	2: [
		Global.StageType.B,
		Global.StageType.C,
	],
	3: [
		Global.StageType.D,
		Global.StageType.E,
	],
	4: [
		Global.StageType.X
	]
}


# 店頭に並ぶ可能性がある Stage を取得する
func get_active_types():
	return _stage_rank[Global.stage_number]


func get_info(type):
	var _info = _stage_info[type]

	return {
		"title": _info["t"],
		"desc": _info["d"],
		"gate": _info["g"],
	}
