extends Node

# TODO: _is_shop_spawned だけでいい

const SPAWN_HEIGHT_MIN_DEFAULT = 80
const SPAWN_HEIGHT_MAX_DEFAULT = -80 # マイナスが上方向であることに注意する
const ENEMY_SPAWN_COOLTIME_DEFAULT = 3.0 # 敵が何秒ごとに出現するかの基準値


@export var _gate_scene: PackedScene
@export var _enemy_scene: PackedScene
@export var _shop_scene: PackedScene


var _is_gear_shop_spawned = false # 現在 Gear Shop が出現しているかどうか
var _is_gear_shop_respawned = false # 直近で Gear Shop が再出現したかどうか
var _gear_shop_counter = 0 # Gear Shop がトータルで何回出現したか
var _money_counter_gear_shop = 0 # Money を取得するたびに 1 増加する (Gear Shop が出現したら 0 に戻す)
var _money_counter_gear_shop_quota = 3 # Money を何回取るたびに Gear Shop が出現するか

var _is_stage_shop_spawned = false # 現在 Stage Shop が出現しているかどうか

var _is_spawn_gate = false # Gate が出現するかどうか
var _gate_spawn_cooltime = 2.0 # 何秒ごとに Gate が出現するか
var _gate_spawn_timer = 0.0
var _gate_spawn_height_min = SPAWN_HEIGHT_MIN_DEFAULT
var _gate_spawn_height_max = SPAWN_HEIGHT_MAX_DEFAULT

var _is_spawn_enemy = false # Enemy が出現するかどうか
var _enemy_spawn_cooltime = ENEMY_SPAWN_COOLTIME_DEFAULT # 何秒ごとに Enemy が出現するか
var _enemy_spawn_timer = 0.0
var _enemy_spawn_height_min = SPAWN_HEIGHT_MIN_DEFAULT
var _enemy_spawn_height_max = SPAWN_HEIGHT_MAX_DEFAULT


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.rank_changed.connect(_on_rank_changed)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)


func _process(delta):
	_process_spawn_gate(delta)
	_process_spawn_enemy(delta)


func _on_state_changed(_from):
	# ACTIVE
	# Gear Shop も Stage Shop も出現していないなら Gate と Enemy を出現させる
	if Global.state == Global.State.ACTIVE:
		var _is_spawnable = !_is_gear_shop_spawned and !_is_stage_shop_spawned
		_is_spawn_gate = _is_spawnable
		_is_spawn_enemy = _is_spawnable
	# ACTIVE 以外
	# Gate と Enemy を生成しない
	else:
		_is_spawn_gate = false
		_is_spawn_enemy = false


func _on_rank_changed(_from):
	var _target_rank = Global.STAGE_TARGET_RANK[Global.stage_number]

	# Rank が Stage Shop 出現の条件に達した場合: Stage Shop を出現させる
	if (Global.rank == _target_rank):
		Global.stage_number += 1
		_spawn_stage_shop()


func _on_hero_got_money():
	_money_counter_gear_shop += 1

	# Money の取得回数が Gear Shop 出現の条件に達した場合: Gear Shop を出現させる
	if _money_counter_gear_shop_quota <= _money_counter_gear_shop:
		_money_counter_gear_shop = 0

		if !Global.gears.has(Global.GearType.NOS):
			_spawn_gear_shop()


func _on_hero_got_gear(gear):
	match gear:
		Global.GearType.EMP:
			_enemy_spawn_height_max = 0
		Global.GearType.EMS:
			var _ems = [2, 3, 5]
			var _ems_count = Global.gears.count(Global.GearType.EMS)
			_enemy_spawn_cooltime = ENEMY_SPAWN_COOLTIME_DEFAULT / _ems[_ems_count]


func _on_hero_exited_shop():
	_is_gear_shop_spawned = false # 厳密にはまだ存在するがもう存在しない扱いとする
	_is_spawn_gate = true
	_is_spawn_enemy = true

	# SPR 所持 and ショップをスルーした and 再出現ではない 場合: Shop が再出現する
	if Global.gears.has(Global.GearType.SPR) and 0 < Global.shop_through_count and !_is_gear_shop_respawned:
		_spawn_gear_shop()
		_is_gear_shop_respawned = true
	# Shop が再出現しなかった場合: フラグを更新する
	else:
		_is_gear_shop_respawned = false


# Gate を生成しつづける (_process 内で呼ぶ)
func _process_spawn_gate(delta):
	if _is_spawn_gate:
		_gate_spawn_timer += delta

	if _gate_spawn_cooltime < _gate_spawn_timer:
		var _rng = RandomNumberGenerator.new()
		var _height_diff = _rng.randf_range(_gate_spawn_height_min, _gate_spawn_height_max)
		var _x_diff = 0
		_gate_spawn_timer = 0

		if Global.gears.has(Global.GearType.GTM):
			var _gtm = [null, 2, 3, 5]
			var _gtm_count = Global.gears.count(Global.GearType.GTM)
			for g in _gtm[_gtm_count]:
				_spawn_gate(_height_diff, _x_diff, g == 0)
				_x_diff += 40
		else:
			_spawn_gate(_height_diff, _x_diff, true)


# Gate を生成する
func _spawn_gate(height_diff, x_diff, set_money):
	var _gate = _gate_scene.instantiate()
	_gate.position.x += (get_viewport().get_camera_2d().global_position.x + 400 + x_diff)
	_gate.position.y += 320
	_gate.gap_diff = Global.gate_gap_diff
	_gate.height_diff += height_diff
	_gate.set_money = set_money
	add_child(_gate)
	#print("[Spawner] spawned a gate.")


# Enemy を生成しつづける (_process 内で呼ぶ)
func _process_spawn_enemy(delta):
	if Global.gears.has(Global.GearType.NOE):
		return

	if _is_spawn_enemy:
		_enemy_spawn_timer += delta

	if _enemy_spawn_cooltime < _enemy_spawn_timer:
		_spawn_enemy()
		_enemy_spawn_timer = 0


# Enemy を生成する
func _spawn_enemy():
	var _enemy = _enemy_scene.instantiate()
	var _rng = RandomNumberGenerator.new()
	var _height_diff = _rng.randf_range(_enemy_spawn_height_min, _enemy_spawn_height_max)
	_enemy.position.x += (get_viewport().get_camera_2d().global_position.x + 400)
	_enemy.position.y += (_height_diff + 320)
	add_child(_enemy)
	#print("[Spawner] spawned a enemy.")


# Gear Shop を生成する
func _spawn_gear_shop():
	_is_gear_shop_spawned = true
	_is_spawn_gate = false
	_is_spawn_enemy = false
	_gear_shop_counter += 1

	var _shop = _shop_scene.instantiate()
	_shop.position.x += (get_viewport().get_camera_2d().global_position.x + 800)
	add_child(_shop)
	_shop.initialize_gear(_gear_shop_counter)
	print("[Spawner] spawned a gear shop.")


# Stage Shop を生成する
func _spawn_stage_shop():
	_is_stage_shop_spawned = true
	_is_spawn_gate = false
	_is_spawn_enemy = false

	var _shop = _shop_scene.instantiate()
	_shop.position.x += (get_viewport().get_camera_2d().global_position.x + 800)
	add_child(_shop)
	_shop.initialize_stage()
	print("[Spawner] spawned a stage shop.")
