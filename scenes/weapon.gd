extends Area2D


# Variables
var speed = 0 # 飛行速度 (px/s)

# Constants
const SPEED_FROM = 200
const SPEED_TO = 800
const SPEED_DURATION = 1.0


func _ready():
	var _tween = create_tween()
	_tween.set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN)
	_tween.tween_method(func(v): speed = v, SPEED_FROM, SPEED_TO, SPEED_DURATION)


func _process(delta):
	position.x += speed * delta


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		if area.is_active && !area.is_dead:
			print("Weapon kills enemy.")
			area.die() # area = enemy
			Global.hero_kills_enemy.emit()


func _on_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("Weaspon is destroyed.")
		queue_free()
