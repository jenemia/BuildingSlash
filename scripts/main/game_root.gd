extends Node2D

@export var ground_bottom_margin: float = 0.0
@export var player_spawn_height_from_ground: float = 16.0
@export var lock_camera_to_viewport: bool = true

@onready var ground: StaticBody2D = $Ground
@onready var ground_collision: CollisionShape2D = $Ground/CollisionShape2D
@onready var ground_visual: Polygon2D = $Ground/GroundVisual
@onready var player: Node2D = $Player
@onready var player_collision: CollisionShape2D = $Player/CollisionShape2D
@onready var camera: Camera2D = $Player/Camera2D
@onready var version_label: Label = get_node_or_null("VersionOverlay/VersionLabel")

@export var version_margin_right: float = 20.0
@export var version_margin_top: float = 12.0

func _ready() -> void:
	_update_version_label()
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
		player.position.y = top_y - _get_player_ground_offset()

	if camera != null and lock_camera_to_viewport:
		camera.top_level = true
		camera.global_position = viewport_size * 0.5

	_layout_version_label(viewport_size)

func _get_player_ground_offset() -> float:
	if player_collision == null:
		return player_spawn_height_from_ground

	var rect := player_collision.shape as RectangleShape2D
	if rect == null:
		return player_spawn_height_from_ground

	return player_collision.position.y + rect.size.y * 0.5

func _update_version_label() -> void:
	if version_label == null:
		return
	var version := str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	version_label.text = "v%s" % version

func _layout_version_label(viewport_size: Vector2) -> void:
	if version_label == null:
		return

	# 해상도 대응: 우상단 고정
	var width := 160.0
	version_label.position = Vector2(viewport_size.x - version_margin_right - width, version_margin_top)
	version_label.size = Vector2(width, 28.0)
