extends CharacterBody2D


# Constants
const GRAVITY = 2400.0 # 落ちる速度 (px/s)
const JUMP_VELOCITY = -600.0 # ジャンプの速度 (px/s)
const MAX_VELOCITY = 300.0 # 終端速度 (px/s)
const DEAD_ROTATION_SPEED = 100.0 # 死んだときに回転するスピード

# Nodes
var _collision_circle = null
var _hero_sprite = null


func _ready():
	# Node 取得
	_hero_sprite = $Gab
	_collision_circle = $CollisionCircle
	# Signal 接続
	Global.hero_jumped.connect(_jump)
	Global.hero_dead.connect(_dead)
	# 当たり判定に色をつける
	_collision_circle.modulate = Color(255.0, 0.0, 0.0, 0.25)


func _physics_process(delta):
	# 終端速度に達していない場合: 重力を受ける
	if (velocity.y < MAX_VELOCITY):
		velocity.y += GRAVITY * delta

	if (Global.is_game_active):
		move_and_slide()

	if (Global.is_hero_dead):
		move_and_slide()
		_hero_sprite.rotation += DEAD_ROTATION_SPEED * delta


func _jump():
	velocity.y = JUMP_VELOCITY


func _dead():
	# 吹っ飛ぶ
	velocity = Vector2(-200, -900)


func _on_area_2d_area_entered(area):
	# 壁にぶつかった場合
	if (area.is_in_group("Wall")):
		Global.hero_damged.emit()
