extends CharacterBody2D


const GRAVITY = 2400.0 # 落ちる速度 (px/s)
const JUMP_VELOCITY = -600.0 # ジャンプの速度 (px/s)
const MAX_VELOCITY = 300.0 # 終端速度 (px/s)


func _ready():
	# Signal 接続
	Global.jumped.connect(_jump)


func _physics_process(delta):
	if (velocity.y < MAX_VELOCITY):
		velocity.y += GRAVITY * delta
	if (Global.is_game_active):
		move_and_slide()


# ジャンプする
func _jump():
	velocity.y = JUMP_VELOCITY
