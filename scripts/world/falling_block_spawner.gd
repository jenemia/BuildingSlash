extends Node2D

const BlockData = preload("res://scripts/world/block_data.gd")

@export var block_scene: PackedScene
@export var spawn_interval_start: float = 1.8
@export var spawn_interval_min: float = 0.75
@export var difficulty_ramp_seconds: float = 180.0
@export var spawn_x_min: float = 700.0
@export var spawn_x_max: float = 760.0
@export var spawn_y: float = -40.0
@export var use_viewport_spawn_bounds: bool = true
@export var viewport_spawn_margin_x: float = 120.0
@export var viewport_spawn_top_offset: float = 40.0
@export var max_alive_start: int = 1
@export var max_alive_end: int = 3
@export var soft_weight_start: float = 0.55
@export var soft_weight_end: float = 0.20
@export var normal_weight_start: float = 0.35
@export var normal_weight_end: float = 0.45
@export var hard_weight_start: float = 0.10
@export var hard_weight_end: float = 0.35

var _time_left: float = 0.0
var _elapsed: float = 0.0

func _ready() -> void:
	randomize()
	_time_left = spawn_interval_start

func _process(delta: float) -> void:
	_elapsed += delta
	_time_left -= delta
	if _time_left > 0.0:
		return
	_time_left = _current_spawn_interval()
	_spawn_one()

func _spawn_one() -> void:
	if block_scene == null:
		return
	if get_tree().get_nodes_in_group("falling_block").size() >= _current_max_alive():
		return

	var block := block_scene.instantiate() as Node2D
	var spawn_pos := _pick_spawn_position()
	block.position = spawn_pos
	if block.has_method("set_block_tier"):
		block.call("set_block_tier", _pick_tier())
	get_parent().add_child(block)

func _pick_tier() -> int:
	var s := maxf(0.0, _lerp_weight(soft_weight_start, soft_weight_end))
	var n := maxf(0.0, _lerp_weight(normal_weight_start, normal_weight_end))
	var h := maxf(0.0, _lerp_weight(hard_weight_start, hard_weight_end))
	var total := s + n + h
	if total <= 0.0:
		return BlockData.Tier.NORMAL

	var r := randf() * total
	if r < s:
		return BlockData.Tier.SOFT
	if r < s + n:
		return BlockData.Tier.NORMAL
	return BlockData.Tier.HARD

func _difficulty_t() -> float:
	if difficulty_ramp_seconds <= 0.0:
		return 1.0
	return clampf(_elapsed / difficulty_ramp_seconds, 0.0, 1.0)

func _current_spawn_interval() -> float:
	return lerpf(spawn_interval_start, spawn_interval_min, _difficulty_t())

func _current_max_alive() -> int:
	return int(round(lerpf(float(max_alive_start), float(max_alive_end), _difficulty_t())))

func _lerp_weight(start_v: float, end_v: float) -> float:
	return lerpf(start_v, end_v, _difficulty_t())

func _pick_spawn_position() -> Vector2:
	if not use_viewport_spawn_bounds:
		return Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)

	var viewport := get_viewport_rect().size
	var min_x := viewport_spawn_margin_x
	var max_x := maxf(min_x + 1.0, viewport.x - viewport_spawn_margin_x)
	var y := -viewport_spawn_top_offset
	return Vector2(randf_range(min_x, max_x), y)
