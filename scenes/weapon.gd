extends Area2D


# Variables
var speed = 300 # 飛行速度 (px/s)


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
