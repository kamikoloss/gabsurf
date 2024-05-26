extends Node2D


@export var _gates: Node
@export var _gate_top: Node
@export var _gate_bottom: Node
@export var _money: Node
@export var _level_area: Area2D


var gap_diff = 0.0 # デフォルトから何 px 開くか
var height_diff = 0 # デフォルトから何 px 上下に移動するか

var is_set_money = true # 真ん中に Money を配置するか

var is_move = false # 上下に動くか
var move_duration = 0.0 # 1周期に何秒かけて上下に動くか
var move_gap = 0 # 上下に何 px 動くか


func _ready():
	_level_area.area_exited.connect(_on_level_area_exited)

	# Gate を開きを変更する
	_gate_top.position.y -= floor(gap_diff / 2)
	_gate_bottom.position.y += floor(gap_diff / 2)

	# Gate の高さを変更する
	_gates.position.y += height_diff

	# Money を配置する
	if !is_set_money:
		_money.queue_free()

	# 上下に動く
	if is_move:
		_start_move()


func _start_move():
	var _start_position = _gates.position
	var _end_position = Vector2(_start_position.x, _start_position.y + move_gap)

	var _tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.set_loops()
	_tween.tween_property(_gates, "position", _end_position, move_duration / 2)
	_tween.tween_property(_gates, "position", _start_position, move_duration / 2)


func _on_level_area_exited(area):
	if area.is_in_group("Screen"):
		#print("[Gate] destroyed.")
		queue_free()
