extends Node

class_name StageShop


# Stage の情報
# "g": Gate 1枚で LEVEL がいくつ増えるか
# "t": 名称, "d1": 説明文メイン, "d2": 説明文サブ
var _stage_info = {
	# Stage 1
	Global.StageType.A: { "g": 1, "t": "ビル街", "d1": ""},
	# Stage 2
	Global.StageType.B: { "g": 3, "t": "B", "d1": "ショップを通過するごとに\nゲートの狭さ -8" },
	Global.StageType.C: { "g": 2, "t": "C", "d1": "ゲートが上下に動く\n (速度: 低)" },
	# Stage 3
	Global.StageType.D: { "g": 5, "t": "D", "d1": "ショップを通過するごとに\nゲートの狭さ -16" },
	Global.StageType.E: { "g": 3, "t": "E", "d1": "" },
	# Stage EX
	Global.StageType.X: { "g": 5, "t": "成層圏", "d1": "重力 1/2", "d2": "GATE = LEVEL +5" },
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


func get_random(ignore = null):
	pass


func get_info(type):
	pass
