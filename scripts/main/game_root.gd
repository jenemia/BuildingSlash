extends Node2D

@export var ground_bottom_margin: float = 0.0
@export var min_ground_width: float = 1280.0
@export var player_spawn_gap_from_ground: float = 160.0
@export var hud_margin_right: float = 20.0
@export var hud_margin_top: float = 16.0
@export var camera_x_ratio: float = 0.30
@export var camera_y_ratio: float = 0.19

@onready var ground: StaticBody2D = $Ground
@onready var ground_collision: CollisionShape2D = $Ground/CollisionShape2D
@onready var ground_visual: Polygon2D = $Ground/GroundVisual
@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var version_label: Label = $HUD/VersionLabel

func _ready() -> void:
	_layout_for_viewport()
	if get_viewport() != null:
		get_viewport().size_changed.connect(_layout_for_viewport)
	_update_version_label()

func _layout_for_viewport() -> void:
	if ground_collision == null:
		return

	var viewport_size := get_viewport_rect().size
	var rect := ground_collision.shape as RectangleShape2D
	if rect == null:
		return

	var width := maxf(min_ground_width, viewport_size.x)
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
		player.position.y = minf(player.position.y, top_y - player_spawn_gap_from_ground)

	if camera != null:
		camera.position = Vector2(viewport_size.x * camera_x_ratio, viewport_size.y * camera_y_ratio)

	if version_label != null:
		var s := version_label.size
		version_label.position = Vector2(viewport_size.x - hud_margin_right - s.x, hud_margin_top)

func _update_version_label() -> void:
	if version_label == null:
		return
	version_label.text = "v%s" % _read_version()

func _read_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))
