extends CharacterBody2D


# Nodes
@onready var _hero_sprite = $AnimatedSprite2D
@onready var _collision_circle = $CollisionCircle

# Constants
const MOVE_VELOCITY = 200 # 横移動の速度 (px/s)
const JUMP_VELOCITY = -600 # ジャンプの速度 (px/s)
const FALL_VELOCITY = 2400 # 落下速度 (px/s)
const FALL_VELOCITY_MAX = 300 # 終端速度 (px/s)
const DEAD_VELOCITY = Vector2(200, -800) # 死んだときに吹き飛ぶベクトル
const DEAD_ROTATION_SPEED = -20 # 死んだときに回転するスピード


func _ready():
	# Signal 接続
	Global.hero_jumped.connect(_jump)
	Global.hero_dead.connect(_dead)


func _physics_process(delta):
	# 終端速度に達していない場合: 落下する
	if (velocity.y < FALL_VELOCITY_MAX):
		velocity.y += FALL_VELOCITY * delta

	# ゲームが進行中の場合: 横に動き続ける + 落下する
	if (Global.is_game_active):
		velocity.x = MOVE_VELOCITY
		move_and_slide()

	# Hero が死んでいる場合: 回転する + 落下する
	# 吹き飛ぶ処理は一度きりの設定なので _dead() 内でやる
	if (Global.is_hero_dead):
		_hero_sprite.rotation += DEAD_ROTATION_SPEED * delta
		move_and_slide()


func _jump():
	if (Global.is_hero_dead):
		return

	velocity.y = JUMP_VELOCITY
	_hero_sprite.stop()
	_hero_sprite.play("jump")


func _dead():
	# 吹き飛ぶ
	velocity = DEAD_VELOCITY
	_hero_sprite.stop()
	_hero_sprite.play("dead")


func _on_area_2d_area_entered(area):
	# 壁にぶつかったとき: ダメージを受ける
	if (area.is_in_group("Wall")):
		Global.hero_damged.emit()

	# Money にぶつかったとき: Money を取得する
	if (area.is_in_group("Money")):
		Global.hero_got_money.emit()
		area.queue_free()
