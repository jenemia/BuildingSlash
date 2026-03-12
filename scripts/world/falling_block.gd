extends CharacterBody2D

@export var max_floors: int = 10
@export var floor_height: float = 28.0
@export var floor_width: float = 180.0
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 520.0
@export var despawn_y: float = 980.0
@export var debug_print: bool = false

signal touched_player(player: Node)

var current_floors: int

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_visual: Polygon2D = $BodyVisual

func _ready() -> void:
	current_floors = max_floors
	add_to_group("hittable")
	add_to_group("falling_block")
	_rebuild_visual_and_collision()

func _physics_process(delta: float) -> void:
	var gravity := ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) as float
	velocity.y = minf(velocity.y + gravity * gravity_scale * delta, max_fall_speed)
	move_and_slide()

	if global_position.y > despawn_y:
		if debug_print:
			print("[FallingBlock] despawned out-of-bounds y=%.1f" % global_position.y)
		queue_free()
		return

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		if col == null:
			continue
		var collider := col.get_collider()
		if collider is Node and collider.is_in_group("player"):
			emit_signal("touched_player", collider)
			if debug_print:
				print("[FallingBlock] touched player=%s" % collider.name)

func take_hit(damage: int, source: Node) -> void:
	var floors_lost: int = max(1, damage)
	current_floors = max(0, current_floors - floors_lost)
	if debug_print:
		print("[FallingBlock] hit by=%s floors=%d/%d" % [source.name, current_floors, max_floors])
	if current_floors <= 0:
		queue_free()
		return
	_rebuild_visual_and_collision()

func _rebuild_visual_and_collision() -> void:
	var total_h := current_floors * floor_height

	var shape := collision_shape.shape as RectangleShape2D
	shape.size = Vector2(floor_width, total_h)
	collision_shape.position = Vector2(0.0, -total_h * 0.5)

	var points := PackedVector2Array([
		Vector2(-floor_width * 0.5, -total_h),
		Vector2(floor_width * 0.5, -total_h),
		Vector2(floor_width * 0.5, 0),
		Vector2(-floor_width * 0.5, 0)
	])
	body_visual.polygon = points
	body_visual.vertex_colors = _build_floor_vertex_colors()
	queue_redraw()

func _build_floor_vertex_colors() -> PackedColorArray:
	return PackedColorArray([
		Color(0.70, 0.75, 0.82, 1.0),
		Color(0.70, 0.75, 0.82, 1.0),
		Color(0.60, 0.65, 0.72, 1.0),
		Color(0.60, 0.65, 0.72, 1.0)
	])

func _draw() -> void:
	var total_h := current_floors * floor_height
	var left := -floor_width * 0.5
	var right := floor_width * 0.5

	for i in range(current_floors):
		var y_top := -total_h + i * floor_height
		var y_bottom := y_top + floor_height
		var t := float(i) / maxf(1.0, float(max_floors - 1))
		var floor_color := Color.from_hsv(0.58 - t * 0.45, 0.55, 0.95, 0.45)
		draw_rect(Rect2(Vector2(left, y_top), Vector2(floor_width, floor_height - 1.0)), floor_color, true)
		draw_line(Vector2(left, y_bottom), Vector2(right, y_bottom), Color(0.12, 0.12, 0.16, 0.75), 1.5)

	draw_rect(Rect2(Vector2(left, -total_h), Vector2(floor_width, total_h)), Color(0.1, 0.1, 0.14, 0.95), false, 2.0)
