extends Node

class_name StageShop


# Stage の情報
# "t": 名称, "d1": 説明文メイン, "d2": 説明文サブ
var _stage_info = {
	# Stage 1
	Global.StageType.A: { "t": "ビル街", "d1": "" },
	# Stage 2
	Global.StageType.B: { "t": "B", "d1": "" },
	Global.StageType.C: { "t": "C", "d1": "ゲートが上下に動く" },
	# Stage 3
	Global.StageType.D: { "t": "D", "d1": "Shop を通過するごとに\nゲートの狭さ -16" },
	Global.StageType.E: { "t": "E", "d1": "" },
	# Stage EX
	Global.StageType.X: { "t": "成層圏", "d1": "重力 1/2", "d2": "GATE = LEVEL +5" },
}
