extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval: float = 1.4
@export var spawn_x_min: float = 260.0
@export var spawn_x_max: float = 1120.0
@export var spawn_y: float = -120.0
@export var max_alive: int = 8

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
	if enemy_scene == null:
		return
	if get_tree().get_nodes_in_group("hittable").size() >= max_alive:
		return

	var enemy := enemy_scene.instantiate() as Node2D
	enemy.position = Vector2(randf_range(spawn_x_min, spawn_x_max), spawn_y)
	get_parent().add_child(enemy)
