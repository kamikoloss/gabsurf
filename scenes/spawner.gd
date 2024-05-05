extends Node2D

# Scenes
const GATE_SCENE = preload("res://scenes/gate.tscn")
const ENEMY_SCENE = preload("res://scenes/enemy.tscn")
const SHOP_SCENE = preload("res://scenes/shop.tscn")


# Constants
const SPAWN_HEIGHT_MIN_DEFAULT = 80
const SPAWN_HEIGHT_MAX_DEFAULT = -80 # マイナスが上であることに注意する
const ENEMY_SPAWN_COOLTIME_DEFAULT = 3.0 # 敵が何秒ごとに出現するかの基準値


# Variables
var _money_counter_shop = 0 # Money を取得するたびに 1 増加する Shop が出現したら 0 に戻す
var _money_counter_shop_quota = 3 # Money を何回取るたびに Shop が出現するか
var _shop_counter = 0 # Shop を生成するたびに 1 増加する

var _is_spawn_gate = false # Gate を生成するか
var _gate_spawn_cooltime = 2.0 # 何秒ごとに Gate を生成するか
var _gate_spawn_timer = 0.0
var _gate_spawn_height_min = SPAWN_HEIGHT_MIN_DEFAULT
var _gate_spawn_height_max = SPAWN_HEIGHT_MAX_DEFAULT

var _is_spawn_enemy = false # Enemy を生成するか
var _enemy_spawn_cooltime = ENEMY_SPAWN_COOLTIME_DEFAULT # 何秒ごとに Enemy を生成するか
var _enemy_spawn_timer = 0.0
var _enemy_spawn_height_min = SPAWN_HEIGHT_MIN_DEFAULT
var _enemy_spawn_height_max = SPAWN_HEIGHT_MAX_DEFAULT


func _ready():
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)
	Global.state_changed.connect(_on_state_changed)

	_is_spawn_gate = false
	_is_spawn_enemy = false


func _process(delta):
	_process_spawn_gate(delta)
	_process_spawn_enemy(delta)


func _on_hero_got_money():
	_money_counter_shop += 1

	# Money の取得回数が Shop 生成の規定回数に達した場合
	if _money_counter_shop_quota <= _money_counter_shop:
		_money_counter_shop = 0

		if Gear.my_gears.has(Gear.GearType.NOS):
			return
		_is_spawn_gate = false
		_is_spawn_enemy = false
		_shop_counter += 1
		_spawn_shop()


func _on_hero_got_gear(gear):
	match gear:
		Gear.GearType.EMP:
			_enemy_spawn_height_max = 0
		Gear.GearType.EMS:
			var _ems = [2, 3, 5]
			var _ems_count = Gear.my_gears.count(Gear.GearType.EMS)
			_enemy_spawn_cooltime = ENEMY_SPAWN_COOLTIME_DEFAULT / _ems[_ems_count]


func _on_hero_exited_shop():
	if Global.state == Global.State.ACTIVE:
		_is_spawn_gate = true
		_is_spawn_enemy = true


func _on_state_changed(from):
	var _is_active = Global.state == Global.State.ACTIVE
	_is_spawn_gate = _is_active
	_is_spawn_enemy = _is_active


# ゲートを生成しつづける (_process 内で呼ぶ)
func _process_spawn_gate(delta):
	if _is_spawn_gate:
		_gate_spawn_timer += delta

	if _gate_spawn_cooltime < _gate_spawn_timer:
		var _gtm = [1, 2, 3, 5]
		var _gtm_count = Gear.my_gears.count(Gear.GearType.GTM)
		var _rng = RandomNumberGenerator.new()
		var _height_diff = _rng.randf_range(_gate_spawn_height_min, _gate_spawn_height_max)
		var _x_diff = 0
		for g in _gtm[_gtm_count]:
			_spawn_gate(_height_diff, _x_diff, g == 0)
			_x_diff += 40
		_gate_spawn_timer = 0


# ゲートを生成する
func _spawn_gate(height_diff, x_diff, set_money):
	var _gate = GATE_SCENE.instantiate()
	_gate.global_position.x += (get_viewport().get_camera_2d().global_position.x + 400 + x_diff)
	_gate.global_position.y += 320
	_gate.gap_diff = Global.gate_gap_diff
	_gate.height_diff += height_diff
	_gate.set_money = set_money
	self.add_child(_gate)
	print("[Spawner] spawned a gate.")


# 敵を生成しつづける (_process 内で呼ぶ)
func _process_spawn_enemy(delta):
	if Gear.my_gears.has(Gear.GearType.NOE):
		return

	if _is_spawn_enemy:
		_enemy_spawn_timer += delta

	if _enemy_spawn_cooltime < _enemy_spawn_timer:
		_spawn_enemy()
		_enemy_spawn_timer = 0


# 敵を生成する
func _spawn_enemy():
	var _enemy = ENEMY_SCENE.instantiate()
	var _rng = RandomNumberGenerator.new()
	var _height_diff = _rng.randf_range(_enemy_spawn_height_min, _enemy_spawn_height_max)
	_enemy.global_position.x += (get_viewport().get_camera_2d().global_position.x + 400)
	_enemy.global_position.y += (_height_diff + 320)
	self.add_child(_enemy)
	print("[Spawner] spawned a enemy.")


# 店を生成する
func _spawn_shop():
	var _shop = SHOP_SCENE.instantiate()
	_shop.global_position.x += (get_viewport().get_camera_2d().global_position.x + 1000)
	_shop.global_position.y += 320
	_shop.number = _shop_counter
	_shop.gate_gap = Global.gate_gap_diff
	self.add_child(_shop)
	print("[Spawner] spawned a shop.")
