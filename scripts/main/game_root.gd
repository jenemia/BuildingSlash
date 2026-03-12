extends Node2D

@export var ground_bottom_margin: float = 0.0
@export var player_spawn_height_from_ground: float = 16.0
@export var hud_margin_right: float = 20.0
@export var hud_margin_top: float = 16.0
@export var lock_camera_to_viewport: bool = true

@onready var ground: StaticBody2D = $Ground
@onready var ground_collision: CollisionShape2D = $Ground/CollisionShape2D
@onready var ground_visual: Polygon2D = $Ground/GroundVisual
@onready var player: Node2D = $Player
@onready var camera: Camera2D = $Player/Camera2D
@onready var version_label: Label = $HUD/VersionLabel
@onready var special_gauge_label: Label = $HUD/SpecialGaugeLabel

func _ready() -> void:
	_layout_for_viewport()
	if get_viewport() != null:
		get_viewport().size_changed.connect(_layout_for_viewport)
	_update_version_label()
	_bind_special_signal()
	_update_special_gauge_label()

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

	if version_label != null:
		var s := version_label.size
		version_label.position = Vector2(viewport_size.x - hud_margin_right - s.x, hud_margin_top)

func _update_version_label() -> void:
	if version_label == null:
		return
	version_label.text = "v%s" % _read_version()

func _read_version() -> String:
	return str(ProjectSettings.get_setting("application/config/version", "0.0.0"))

func _process(_delta: float) -> void:
	_update_special_gauge_label()

func _bind_special_signal() -> void:
	if player == null:
		return
	var special_component: Node = player.get_node_or_null("SpecialComponent")
	if special_component == null:
		return
	if special_component.has_signal("gauge_changed"):
		special_component.connect("gauge_changed", _on_special_gauge_changed)

func _on_special_gauge_changed(_current: float, _max_value: float) -> void:
	_update_special_gauge_label()

func _update_special_gauge_label() -> void:
	if special_gauge_label == null or player == null:
		return
	if not player.has_method("get_special_ratio"):
		special_gauge_label.text = "SPECIAL --"
		return
	var ratio := float(player.call("get_special_ratio"))
	special_gauge_label.text = "SPECIAL %d%%" % int(round(ratio * 100.0))
