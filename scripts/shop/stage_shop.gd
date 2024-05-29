extends Node
class_name StageShop


# Stage の情報
# "i": アイコン画像のパス, "t": 名称, "d": 説明文
var _stage_info = {
	# Stage 1
	Global.StageType.A: { "i": "res://images/stage.png", "t": "平和な街", "d": ""},
	# Stage 2
	Global.StageType.B: { "i": "res://images/stage.png", "t": "物騒な街", "d": "ショップを通過するごとに\nゲートの狭さ -8" },
	Global.StageType.C: { "i": "res://images/stage.png", "t": "ノリノリな街", "d": "ゲートが上下に動く" },
	# Stage 3
	Global.StageType.D: { "i": "res://images/stage.png", "t": "かなり物騒な街", "d": "ショップを通過するごとに\nゲートの狭さ -16" },
	Global.StageType.E: { "i": "res://images/stage.png", "t": "薄暗い街", "d": "深い霧に包まれて\n視界が悪くなる" },
	# Stage X
	Global.StageType.X: { "i": "res://images/stage.png", "t": "遠い街", "d": "どこまで行けるか\n試してみよう"},
}

# Stage Number ごとに店に並ぶ Stage のリスト
var _stage_rank = {
	1: [
		Global.StageType.B,
		Global.StageType.C,
	],
	2: [
		Global.StageType.D,
		Global.StageType.E,
	],
	3: [
		Global.StageType.X
	]
}


# 店頭に並ぶ可能性がある Stage を取得する
func get_active_types():
	return _stage_rank[Global.stage_number]


func get_info(type):
	var _info = _stage_info[type]

	return {
		"icon": load(_info["i"]),
		"title": _info["t"],
		"desc": _info["d"],
		"gate": _info["g"],
	}
