extends Area2D


# Variables
var speed = 300 # 飛行速度 (px/s)

# Constants
const DESTROY_TIME = 5 # 生まれて何秒後に自身を破壊するか


func _ready():
	_destroy()


func _process(delta):
	position.x += speed * delta


# 指定秒数後に自身を破壊する
func _destroy():
	await get_tree().create_timer(DESTROY_TIME).timeout
	#print("Weaspon is destroyed.")
	queue_free()


func _on_area_entered(area):
	if area.is_in_group("Enemy"):
		print("Weapon kills enemy.")
		area.die() # area = enemy
		Global.hero_kills_enemy.emit()
