extends Area2D


const SPEED_FROM = 200
const SPEED_TO = 800
const SPEED_DURATION = 1.0

const DESTROY_TIME = 10 # 生まれて何秒後に自身を破壊するか


var speed = 0 # 飛行速度 (px/s)


func _ready():
	var _tween = create_tween()
	_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.tween_method(func(v): speed = v, SPEED_FROM, SPEED_TO, SPEED_DURATION)

	_auto_destroy()


func _process(delta):
	position.x += speed * delta


# 指定秒数後に自身を破壊する
func _auto_destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	print("[Weapon] destroyed.")
	queue_free()
