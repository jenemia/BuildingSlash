extends Node2D

@export var ground_bottom_margin: float = 0.0
@export var player_spawn_height_from_ground: float = 16.0
@export var lock_camera_to_viewport: bool = true

@onready var ground: StaticBody2D = $Ground
@onready var ground_collision: CollisionShape2D = $Ground/CollisionShape2D
@onready var ground_visual: Polygon2D = $Ground/GroundVisual
@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Player/Camera2D

func _ready() -> void:
	_layout_for_viewport()
	if get_viewport() != null:
		get_viewport().size_changed.connect(_layout_for_viewport)

func _layout_for_viewport() -> void:
	if ground_collision == null:
		return

	var viewport_size := get_viewport_rect().size
	var rect := ground_collision.shape as RectangleShape2D
	if rect == null:
		return

	var width := viewport_size.x
	rect.size = Vector2(width, rect.size.y)

	var half_h := rect.size.y * 0.5
	ground.position.y = viewport_size.y - ground_bottom_margin - half_h
	ground.position.x = viewport_size.x * 0.5

	if ground_visual != null:
		ground_visual.polygon = PackedVector2Array([
			Vector2(-width * 0.5, -half_h),
			Vector2(width * 0.5, -half_h),
			Vector2(width * 0.5, half_h),
			Vector2(-width * 0.5, half_h),
		])

	if player != null:
		var top_y := ground.position.y - half_h
		player.position.y = top_y - player_spawn_height_from_ground

	if camera != null and lock_camera_to_viewport:
		camera.top_level = true
		camera.global_position = viewport_size * 0.5
