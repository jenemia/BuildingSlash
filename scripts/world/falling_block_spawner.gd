extends Node2D

@export var block_scene: PackedScene
@export var spawn_interval: float = 1.8
@export var spawn_x_min: float = 700.0
@export var spawn_x_max: float = 760.0
@export var spawn_y: float = -40.0
@export var max_alive: int = 1

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
	get_parent().add_child(block)
