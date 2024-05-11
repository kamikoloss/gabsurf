extends Area2D


const SPEED_FROM = 200
const SPEED_TO = 800
const SPEED_DURATION = 1.0


var speed = 0 # 飛行速度 (px/s)


func _ready():
	var _tween = create_tween()
	_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.tween_method(func(v): speed = v, SPEED_FROM, SPEED_TO, SPEED_DURATION)


func _process(delta):
	position.x += speed * delta


func _on_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("[Weapon] destroyed.")
		queue_free()
