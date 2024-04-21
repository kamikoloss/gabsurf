extends Node


# ギアの種類
enum GearType {
	DBL,
	DEC,
	EXT,
	JET,
	KIL,
	LIF,
	MIS,
	SHO,
}


# ギアの情報
const GEAR_INFO = {
	GearType.DBL: { "t": "ダブルタップ", "d": "ゲートが2個ずつ\n出てくるようになる", "c": 3,  "i": null },
	GearType.DEC: { "t": "デコンパイラ", "d": "ガブと敵の当たり判定が\n見えるようになる", "cost": 3, "icon":  null },
	GearType.EXT: { "t": "エナジーフード", "d": "EXTRA +1", "c": 3, "i": null },
	GearType.JET: { "t": "ジェットエンジン", "d": "進行速度 x1.5\nEXTRA +10", "c": 3,  "i": null },
	GearType.KIL: { "t": "狩猟免許", "d": "敵を倒すたびに\nEXTRA +1",  "c": 3, "i": null },
	GearType.LIF: { "t": "生命保険", "d": "残機 +1", "c": 3, "i": null },
	GearType.MIS: { "t": "ミサイル", "d": "n秒ごとにミサイルを発射する",  "c": 3, "i": null, },
	GearType.SHO: { "t": "安全靴", "d": "敵を踏めるようになる", "c": 3, "i": null },
}
