extends Node2D


@export var _gate_top: Node
@export var _gate_bottom: Node
@export var _money: Node


var gap_diff = 0.0 # デフォルトから何 px 開くか
var height_diff = 0 # デフォルトから何 px 上下に移動するか

var is_set_money = true # 真ん中に Money を配置するか

var is_move = false # 上下に動くか
var move_duration = 0.0 # 1周期に何秒かけて上下に動くか
var move_gap = 0 # 上下に何 px 動くか


func _ready():
	# Gate を開く
	_gate_top.position.y -= floor(gap_diff / 2)
	_gate_bottom.position.y += floor(gap_diff / 2)

	# Gate の Y 座標を移動する
	_gate_top.position.y += height_diff
	_gate_bottom.position.y += height_diff
	_money.position.y += height_diff

	# Money を配置する
	if !is_set_money:
		_money.queue_free()
		
	# 上下に動く
	if is_move:
		_start_move()


func _start_move():
	var _start_position = position
	var _end_position = Vector2(_start_position.x, _start_position.y + move_gap)

	var _tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.set_loop() # 無限にループする
	_tween.tween_property(self, "position", _end_position, move_duration / 2)
	_tween.tween_property(self, "position", _start_position, move_duration / 2)


func _on_area_2d_area_exited(area):
	if area.is_in_group("ScreenOut"):
		#print("[Gate] destroyed.")
		queue_free()
