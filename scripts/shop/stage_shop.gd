extends Node
class_name StageShop


@export var _icons: Array[Texture]


# Stage の情報
# "g": Gate 1枚で LEVEL がいくつ増えるか, "i": _icons index,
# "t": 名称, "d": 説明文
var _stage_info = {
	# Stage 1
	Global.StageType.A: { "g": 1, "i": 0, "t": "平和な街", "d": ""},
	# Stage 2
	Global.StageType.B: { "g": 3, "i": 0, "t": "物騒な街", "d": "ショップを通過するごとに\nゲートの狭さ -8" },
	Global.StageType.C: { "g": 2, "i": 0, "t": "ノリノリな街", "d": "ゲートが上下に動く" },
	# Stage 3
	Global.StageType.D: { "g": 5, "i": 0, "t": "かなり物騒な街", "d": "ショップを通過するごとに\nゲートの狭さ -16" },
	Global.StageType.E: { "g": 3, "i": 0, "t": "薄暗い街", "d": "深い霧に包まれて\n視界が悪くなる" },
	# Stage X
	Global.StageType.X: { "g": 5, "i": 0, "t": "遠い街", "d": "どこまで行けるか\n試してみよう"},
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
	var _icon = null

	# アイコン画像
	# 使用しない可能性 (_icons が空の可能性) もある
	if 0 < _icons.size():
		_icon = _icons[_info["i"]]

	return {
		"icon": _icon,
		"title": _info["t"],
		"desc": _info["d"],
		"gate": _info["g"],
	}
