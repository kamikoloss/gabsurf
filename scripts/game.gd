extends Node2D


const SLOW_SPEED_GEAR_SHOP = 0.6 # Gear Shop に入ったときに何倍速のスローになるか
const SLOW_DURATION_GEAR_SHOP = 1.0 # Gear Shop に入ったときに何秒かけてスローになるか
const SLOW_SPEED_STAGE_SHOP = 0.4 # Stage Shop に入ったときに何倍速のスローになるか
const SLOW_DURATION_STAGE_SHOP = 1.0 # Stage Shop に入ったときに何秒かけてスローになるか
const SLOW_SPEED_GAMEOVER = 0.2 # ゲームオーバー時に何倍速のスローになるか
const SLOW_DURATION_GAMEOVER = 1.0 # ゲームオーバー時に何秒かけてスローになるか

const GATE_GAP_STEP = 16 # Gate が難易度上昇で何 px ずつ狭くなっていくか
const LEVEL_BASE = 1 # Gate 通過時に Level に加算される値


@export var _screen: Area2D


var _slow_tween = null


func _ready():
	Engine.time_scale = 1.0

	Global.state_changed.connect(_on_state_changed)
	Global.stage_changed.connect(_on_stage_changed)
	Global.ui_jumped.connect(_on_ui_jumped)
	Global.ui_paused.connect(_on_ui_paused)
	Global.ui_retried.connect(_on_ui_retried)
	Global.hero_got_level.connect(_on_hero_got_level)
	Global.hero_got_money.connect(_on_hero_got_money)
	Global.hero_got_gear.connect(_on_hero_got_gear)
	Global.hero_entered_shop.connect(_on_hero_entered_shop)
	Global.hero_exited_shop.connect(_on_hero_exited_shop)
	Global.enemy_dead.connect(_on_enemy_dead)

	Global.initialize()


func _process(_delta):
	_screen.position.x = get_viewport().get_camera_2d().global_position.x


func _on_state_changed(_from):
	match Global.state:
		# タイトル画面
		Global.State.TITLE:
			print("---------------- TITLE ----------------")
			get_tree().paused = true
		# ゲーム中
		Global.State.ACTIVE:
			print("---------------- ACTIVE ----------------")
			get_tree().paused = false
		# ポーズ中
		Global.State.PAUSED:
			print("---------------- PAUSED ----------------")
			get_tree().paused = true
		# ゲームオーバー
		Global.State.GAMEOVER:
			print("---------------- GAMEOVER ----------------")
			_enter_slow(SLOW_SPEED_GAMEOVER, SLOW_DURATION_GAMEOVER)


func _on_stage_changed(_from):
	Global.stage_number += 1


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


func _on_hero_got_level():
	Global.level += LEVEL_BASE


func _on_hero_got_money():
	Global.money += Global.MONEY_RATIO


func _on_hero_got_gear(gear):
	match gear:
		Global.GearType.EXT:
			Global.extra += 5
		Global.GearType.LFP:
			Global.life += 1
		Global.GearType.LFM:
			if Global.life <= 1:
				print("[Game] try to get gear LFM, but no life!!")
			else:
				Global.life -= 1
				Global.money += 10 * Global.MONEY_RATIO
		Global.GearType.LOT:
			var _rng = RandomNumberGenerator.new()
			var _lot = _rng.randi_range(0, 5)
			Global.money += _lot * Global.MONEY_RATIO


func _on_hero_entered_shop(shop_type: Global.ShopType):
	if Global.state != Global.State.ACTIVE:
		return

	Global.shop_through_count += 1 # Gear を取得したら 0 に戻す

	match shop_type:
		Global.ShopType.GEAR:
			_enter_slow(SLOW_SPEED_GEAR_SHOP, SLOW_DURATION_GEAR_SHOP)
		Global.ShopType.STAGE:
			_enter_slow(SLOW_SPEED_STAGE_SHOP, SLOW_DURATION_STAGE_SHOP)


func _on_hero_exited_shop(shop_type: Global.ShopType):
	if Global.state != Global.State.ACTIVE:
		return

	# SPT
	if Global.gears.has(Global.GearType.SPT) and 0 < Global.shop_through_count:
		# TODO: メッセージ表示
		Global.money += Global.shop_through_count * Global.MONEY_RATIO

	match shop_type:
		Global.ShopType.GEAR:
			_exit_slow(SLOW_DURATION_GEAR_SHOP)
		Global.ShopType.STAGE:
			_exit_slow(SLOW_DURATION_STAGE_SHOP)


func _on_enemy_dead():
	# EME
	if Global.gears.has(Global.GearType.EME):
		var _eme = [0, 1, 2, 3]
		var _eme_count = Global.gears.count(Global.GearType.EME)
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
