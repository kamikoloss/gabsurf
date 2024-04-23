extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const SHOP_SCENE = preload("res://scenes/shop.tscn")

# Nodes
@onready var _hero = $Hero
@onready var _walls = $Walls

# Constants
const SLOW_DURATION = 1.0 # スロー状態に何秒かけて移行するか
const SLOW_SPEED_GAMEOVER = 0.25 # ゲームオーバー時に何倍速のスローになるか
const SLOW_SPEED_SHOP = 0.5 # Shop 入店中に何倍速のスローになるか
const GATE_HEIGHT_MIN = -80 # (px)
const GATE_HEIGHT_MAX = 80 # (px)
const GATE_GAP_STEP = 16 # ゲートが難易度上昇で何 px ずつ狭くなっていくか
const LEVEL_BASE = 10 # ゲート通過時に Level に加算される値

# Variables
var _money_base = 1 # Money 取得時に加算される値
var _gate_gap = 0 # ゲートの開き

var _gate_counter_shop = 0 # ゲートを通るたびに 1 増加する 店が出現したら 0 に戻す
var _gate_counter_shop_quota = 3 # ゲートを何回通るたびに店が出現するか
var _gate_counter_difficult = 0 # ゲートを通るたびに 1 増加する 難易度が上昇したら 0 に戻す
var _gate_counter_difficult_quota = 3 # ゲートを何回通るたびに難易度が上昇するか
var _shop_counter = 0 # 店を生成するたびに 1 増加する

var _is_spawn_gate = false # ゲートを生成するか
var _gate_spawn_cooltime = 2.0 # 何秒ごとにゲートを生成するか
var _gate_spawn_timer = 0.0
var _is_spawn_enemy = false # 敵を生成するか
var _enemy_spawn_cooltime = 3.0 # 何秒ごとに敵を生成するか
var _enemy_spawn_timer = 0.0

var _slow_tween = null
var _rng = RandomNumberGenerator.new()


func _ready():
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.ui_paused.connect(_on_ui_paused)
	Global.ui_retried.connect(_on_ui_retried)
	Global.hero_damged.connect(_on_hero_damged)
	Global.hero_got_level.connect(_on_hero_got_level)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_entered_shop.connect(_on_hero_entered_shop)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)
	Global.hero_got_gear.connect(_on_hero_got_gear)

	_initialize_game()


func _process(delta):
	# Walls を Hero に追随させる
	if (_hero != null):
		_walls.position.x = _hero.position.x

	_process_spawn_gate(delta)
	_process_spawn_enemy(delta)


# ゲームを初期化 + 一時停止する
func _initialize_game():
	print("Waiting start...")
	Engine.time_scale = 1.0
	set_process(false)
	set_physics_process(false)

	Global.initialize()
	Gear.initialize()

	_is_spawn_gate = true
	_is_spawn_enemy = true

	Global.game_initialized.emit()


func _on_ui_jumped():
	# タイトル or ポーズ中 -> ゲーム中
	var states = [Global.GameState.TITLE, Global.GameState.PAUSED]
	if (states.has(Global.game_state)):
		Engine.time_scale = 1.0
		set_process(true)
		set_physics_process(true)
		Global.game_state = Global.GameState.ACTIVE


func _on_ui_paused():
	# ゲーム中 -> ポーズ中
	if (Global.game_state == Global.GameState.ACTIVE):
		Engine.time_scale = 0.0
		set_process(false)
		set_physics_process(false)
		Global.game_state = Global.GameState.PAUSED


func _on_ui_retried():
	# ポーズ中 or ゲームオーバー: シーンを再読み込みする
	var states = [Global.GameState.PAUSED, Global.GameState.GAMEOVER]
	if (states.has(Global.game_state)):
		get_tree().reload_current_scene()


func _on_hero_damged():
	Global.life -= 1

	# Hero の残機が 0 になった場合: ゲームオーバー
	if (Global.life == 0):
		Global.game_state = Global.GameState.GAMEOVER
		_enter_slow(SLOW_SPEED_GAMEOVER)
		print("Game is ended.")
		Global.game_ended.emit()


func _on_hero_got_level():
	Global.level += LEVEL_BASE
	_gate_counter_shop += 1
	_gate_counter_difficult += 1

	# 難易度上昇の規定回数に達した場合
	if (_gate_counter_difficult_quota <= _gate_counter_difficult):
		_gate_counter_difficult = 0
		_gate_gap -= GATE_GAP_STEP
		print("current gate gap: {0}".format([_gate_gap]))

	# 店生成の規定回数に達した場合
	# 店の看板で難易度を表示するので難易度の処理よりあとに書く
	if (_gate_counter_shop_quota <= _gate_counter_shop):
		_gate_counter_shop = 0
		_shop_counter += 1
		_is_spawn_gate = false
		_is_spawn_enemy = false
		_spawn_shop()


func _on_hero_got_money():
	Global.money += _money_base


func _on_hero_entered_shop():
	if (Global.game_state == Global.GameState.ACTIVE):
		_enter_slow(SLOW_SPEED_SHOP)


func _on_hero_exited_shop():
	if (Global.game_state == Global.GameState.ACTIVE):
		_exit_slow()
		_is_spawn_gate = true
		_is_spawn_enemy = true


func _on_hero_got_gear(gear):
	Global.money -= Gear.GEAR_INFO[gear]["c"]
	Gear.my_gears += [gear]

	# ギアの効果を発動する
	match (gear):
		Gear.GearType.EXT:
			Global.extra += 5
		Gear.GearType.JET:
			Global.hero_move_velocity *= 1.25
			Global.extra *= 2
		Gear.GearType.KIL:
			pass
		Gear.GearType.LIF:
			Global.life += 1
		Gear.GearType.MIS:
			pass
		Gear.GearType.SHO:
			pass


# スロー用の Tween を取得する
func _get_slow_tween():
	if (_slow_tween):
		_slow_tween.kill()

	_slow_tween = create_tween()
	_slow_tween.set_trans(Tween.TRANS_QUINT)
	_slow_tween.set_ease(Tween.EASE_OUT)
	return _slow_tween


# 通常速度からスローになっていく
func _enter_slow(speed):
	_get_slow_tween().tween_property(Engine, "time_scale", speed, SLOW_DURATION)


# スローから通常速度になっていく
func _exit_slow():
	_get_slow_tween().tween_property(Engine, "time_scale", 1.0, SLOW_DURATION)


# ゲートを生成する
func _spawn_gate():
	var _gate = GATE_SCENE.instantiate()
	_gate.position.x += (_hero.position.x + 360)
	_gate.position.y += 320
	_gate.gap = _gate_gap
	_gate.height_diff += _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	get_tree().root.get_node("Main").add_child(_gate)
	#print("Gate is spawned.")


# ゲートを生成しつづける (_process 内で呼ぶ)
func _process_spawn_gate(delta):
	if (_is_spawn_gate):
		_gate_spawn_timer += delta

	if (_gate_spawn_cooltime < _gate_spawn_timer):
		_spawn_gate()
		_gate_spawn_timer = 0


# 敵を生成する
func _spawn_enemy():
	var _enemy = ENEMY_SCENE.instantiate()
	var _height_diff = _rng.randf_range(GATE_HEIGHT_MIN, GATE_HEIGHT_MAX)
	_enemy.position.x += (_hero.position.x + 360)
	_enemy.position.y += (_height_diff + 320)
	get_tree().root.get_node("Main").add_child(_enemy)
	#print("Enemy is spawned.")


# 敵を生成しつづける (_process 内で呼ぶ)
func _process_spawn_enemy(delta):
	if (_is_spawn_enemy):
		_enemy_spawn_timer += delta

	if (_enemy_spawn_cooltime < _enemy_spawn_timer):
		_spawn_enemy()
		_enemy_spawn_timer = 0


# 店を生成する
func _spawn_shop():
	var _shop = SHOP_SCENE.instantiate()
	_shop.position.x += (_hero.position.x + 720)
	_shop.position.y += 320
	_shop.number = _shop_counter
	_shop.gate_gap = 256 + _gate_gap
	get_tree().root.get_node("Main").add_child(_shop)
	#print("Shop is spawned.")
