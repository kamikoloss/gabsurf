extends Node2D


# Nodes
@onready var _screen = $Screen
@onready var _hero_anti_damage_bar = $Hero/UI/TextureProgressBar


# Constants
const SLOW_SPEED_SHOP = 0.6 # Shop に入ったときに何倍速のスローになるか
const SLOW_DURATION_SHOP = 1.0 # Shop に入ったときに何秒かけてスローになるか
const SLOW_SPEED_GAMEOVER = 0.2 # ゲームオーバー時に何倍速のスローになるか
const SLOW_DURATION_GAMEOVER = 1.0 # ゲームオーバー時に何秒かけてスローになるか
const GATE_GAP_STEP = 16 # Gate が難易度上昇で何 px ずつ狭くなっていくか
const LEVEL_BASE = 10 # Gate 通過時に Level に加算される値
const DAMAGED_ANTI_DAMAGE_DURATION = 1.0 # Hero が被ダメージ時に何秒間無敵になるか


# Variables
var _money_base = 1 # Money 取得時に加算される値
var _money_counter_difficult = 0 # Money を取るたびに 1 増加する 難易度が上昇したら 0 に戻す
var _money_counter_difficult_quota = 3 #Money を何回取るたびに難易度が上昇するか

var _slow_tween = null
var _anti_damage_tween = null


func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.ui_paused.connect(_on_ui_paused)
	Global.ui_retried.connect(_on_ui_retried)
	Global.hero_got_level.connect(_on_hero_got_level)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_damaged.connect(_on_hero_damaged)
	Global.hero_kills_enemy.connect(_on_hero_kills_enemy)
	Global.hero_entered_shop.connect(_on_hero_entered_shop)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)

	Global.initialize()
	Gear.initialize()


func _process(delta):
	_screen.global_position.x = get_viewport().get_camera_2d().global_position.x


func _on_state_changed(from):
	match Global.state:
		# タイトル画面
		Global.State.TITLE:
			print("---------------- TITLE ----------------")
			Engine.time_scale = 1.0
			set_process(false)
			set_physics_process(false)
			_hero_anti_damage_bar.visible = false
		# ゲーム中
		Global.State.ACTIVE:
			Engine.time_scale = 1.0
			set_process(true)
			set_physics_process(true)
		# ポーズ中
		Global.State.PAUSED:
			Engine.time_scale = 0.0
			set_process(false)
			set_physics_process(false)
		# ゲームオーバー
		Global.State.GAMEOVER:
			print("---------------- GAMEOVER ----------------")
			_enter_slow(SLOW_SPEED_GAMEOVER, SLOW_DURATION_GAMEOVER)


func _on_ui_jumped():
	# タイトル or ポーズ中 -> ゲーム中
	var states = [Global.State.TITLE, Global.State.PAUSED]
	if states.has(Global.state):
		Global.state = Global.State.ACTIVE


func _on_ui_paused():
	# ゲーム中 -> ポーズ中
	if Global.state == Global.State.ACTIVE:
		Global.state = Global.State.PAUSED


func _on_ui_retried():
	# ポーズ中 or ゲームオーバー: シーンを再読み込みする
	var states = [Global.State.PAUSED, Global.State.GAMEOVER]
	if states.has(Global.state):
		get_tree().reload_current_scene()


func _on_hero_damaged():
	# ゲーム中でない: ダメージを受けても何も起きない
	if Global.state != Global.State.ACTIVE:
		return

	Global.life -= 1

	# Hero の残機が 0 になった場合: ゲームオーバー
	if Global.life <= 0:
		Global.state = Global.State.GAMEOVER
	# まだ残機がある場合
	else:
		# 無敵状態ではない: 無敵状態に突入する
		if !Global.is_hero_anti_damage:
			_enter_anti_damage(DAMAGED_ANTI_DAMAGE_DURATION)


func _on_hero_got_level():
	Global.level += LEVEL_BASE


func _on_hero_got_money():
	Global.money += _money_base
	_money_counter_difficult += 1

	# 難易度上昇の規定回数に達した場合
	if _money_counter_difficult_quota <= _money_counter_difficult:
		_money_counter_difficult = 0
		Global.gate_gap_diff -= GATE_GAP_STEP
		print("[Game] current gate gap diff is {0}".format([Global.gate_gap_diff]))


func _on_hero_got_gear(gear):
	Global.money -= Gear.GEAR_INFO[gear]["c"]
	Gear.my_gears += [gear]

	match gear:
		Gear.GearType.EXT:
			Global.extra += 5
		Gear.GearType.GTG:
			Global.gate_gap_diff += 64
		Gear.GearType.LFP:
			Global.life += 1
		Gear.GearType.LFM:
			if Global.life <= 1:
				print("[Game] try to get gear LFM, but no life!!")
			else:
				Global.life -= 1
				Global.money += 10
		Gear.GearType.LOT:
			var _rng = RandomNumberGenerator.new()
			var _lot = _rng.randf_range(0, 5)
			Global.money += _lot
		Gear.GearType.SCL:
			Global.hero_move_velocity *= 1.25
			Global.extra *= 2


func _on_hero_entered_shop():
	if Global.state == Global.State.ACTIVE:
		_enter_slow(SLOW_SPEED_SHOP, SLOW_DURATION_SHOP)


func _on_hero_exited_shop():
	if Global.state == Global.State.ACTIVE:
		_exit_slow(SLOW_DURATION_SHOP)


func _on_hero_kills_enemy():
	# ATD
	if Gear.my_gears.has(Gear.GearType.ATD):
		var _atd = [0, 1, 2, 3]
		var _atd_count = Gear.my_gears.count(Gear.GearType.ATD)
		_enter_anti_damage(_atd[_atd_count])

	# EME
	if Gear.my_gears.has(Gear.GearType.EME):
		var _eme = [0, 1, 2, 3]
		var _eme_count = Gear.my_gears.count(Gear.GearType.EME)
		Global.extra += _eme[_eme_count]


# スロー用の Tween を取得する
func _get_slow_tween():
	if _slow_tween:
		_slow_tween.kill()
	_slow_tween = create_tween()
	_slow_tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	return _slow_tween


# 通常速度からスローになっていく
func _enter_slow(speed, duration):
	var _tween = _get_slow_tween()
	_tween.tween_property(Engine, "time_scale", speed, duration)


# スローから通常速度になっていく
func _exit_slow(duration):
	var _tween = _get_slow_tween()
	_tween.tween_property(Engine, "time_scale", 1.0, duration)


# 無敵時間用の Tween を取得する
func _get_anti_damage_tween():
	if _anti_damage_tween:
		_anti_damage_tween.kill()
	_anti_damage_tween = create_tween()
	_anti_damage_tween.set_trans(Tween.TRANS_LINEAR)
	return _anti_damage_tween


# 無敵状態に突入する
func _enter_anti_damage(duration):
	Global.is_hero_anti_damage = true

	_hero_anti_damage_bar.visible = true
	_hero_anti_damage_bar.value = 100

	var _tween = _get_anti_damage_tween()
	_tween.tween_property(_hero_anti_damage_bar, "value", 0, duration)
	_tween.tween_callback(func(): _hero_anti_damage_bar.visible = false)
	_tween.tween_callback(func(): Global.is_hero_anti_damage = false)
	#_tween.tween_callback(func(): print("[Game] anti-damage is finished."))