extends Node2D

@export var design_height: float = 1080.0
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
@onready var combat_hud: CanvasLayer = get_node_or_null("CombatHUD")
@onready var mobile_joystick: Control = get_node_or_null("MobileControls/MobileJoystick")

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
	if viewport_size.x <= 1.0 or viewport_size.y <= 1.0:
		return

	var safe_rect := _safe_area_rect(viewport_size)
	var zoom := _compute_world_zoom(viewport_size)
	var world_content_size := safe_rect.size * zoom
	var world_center := (safe_rect.position + safe_rect.size * 0.5) * zoom

	var rect := ground_collision.shape as RectangleShape2D
	if rect == null:
		return

	var width := world_content_size.x
	rect.size = Vector2(width, rect.size.y)

	var half_h := rect.size.y * 0.5
	ground.position.y = world_center.y + world_content_size.y * 0.5 - ground_bottom_margin - half_h
	ground.position.x = world_center.x

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
		camera.zoom = Vector2(zoom, zoom)
		camera.global_position = world_center

	_layout_version_label(safe_rect)
	_apply_safe_area_to_ui(safe_rect)

func _compute_world_zoom(viewport_size: Vector2) -> float:
	if design_height <= 0.0:
		return 1.0
	return design_height / viewport_size.y

func _safe_area_rect(viewport_size: Vector2) -> Rect2:
	var safe := Rect2(Vector2.ZERO, viewport_size)
	if DisplayServer.has_method("get_display_safe_area"):
		var safe_rect = DisplayServer.get_display_safe_area()
		if safe_rect is Rect2i:
			var sr := safe_rect as Rect2i
			if sr.size.x > 0 and sr.size.y > 0:
				safe = Rect2(Vector2(sr.position), Vector2(sr.size))
	return safe

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

func _layout_version_label(safe_rect: Rect2) -> void:
	if version_label == null:
		return

	var width := 160.0
	version_label.position = Vector2(safe_rect.end.x - version_margin_right - width, safe_rect.position.y + version_margin_top)
	version_label.size = Vector2(width, 28.0)

func _apply_safe_area_to_ui(safe_rect: Rect2) -> void:
	if combat_hud != null and combat_hud.has_method("apply_safe_area"):
		combat_hud.call("apply_safe_area", safe_rect)
	if mobile_joystick != null and mobile_joystick.has_method("apply_safe_area"):
		mobile_joystick.call("apply_safe_area", safe_rect)
