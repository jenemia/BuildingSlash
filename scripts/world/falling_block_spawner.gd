extends Node2D

const BlockData = preload("res://scripts/world/block_data.gd")

@export var block_scene: PackedScene
@export var spawn_interval: float = 1.8
@export var spawn_x_min: float = 700.0
@export var spawn_x_max: float = 760.0
@export var spawn_y: float = -40.0
@export var max_alive: int = 1
@export var soft_weight: float = 0.55
@export var normal_weight: float = 0.35
@export var hard_weight: float = 0.10

var _time_left: float = 0.0

func _ready() -> void:
	randomize()
	_time_left = spawn_interval

func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left > 0.0:
		return
	_time_left = spawn_interval
	_spawn_one()

func _spawn_one() -> void:
	if block_scene == null:
		return
	if get_tree().get_nodes_in_group("falling_block").size() >= max_alive:
		return

	var block := block_scene.instantiate() as Node2D
	block.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	if block.has_method("set_block_tier"):
		block.call("set_block_tier", _pick_tier())
	get_parent().add_child(block)

func _pick_tier() -> int:
	var s := maxf(0.0, soft_weight)
	var n := maxf(0.0, normal_weight)
	var h := maxf(0.0, hard_weight)
	var total := s + n + h
	if total <= 0.0:
		return BlockData.Tier.NORMAL

	var r := randf() * total
	if r < s:
		return BlockData.Tier.SOFT
	if r < s + n:
		return BlockData.Tier.NORMAL
	return BlockData.Tier.HARD
