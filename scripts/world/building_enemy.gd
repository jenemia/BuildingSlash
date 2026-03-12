extends CharacterBody2D

@export var max_floors: int = 10
@export var floor_height: float = 28.0
@export var floor_width: float = 180.0
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 520.0
@export var debug_print: bool = false

var current_floors: int

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_visual: Polygon2D = $BodyVisual

func _ready() -> void:
	current_floors = max_floors
	add_to_group("hittable")
	add_to_group("building_enemy")
	_rebuild_visual_and_collision()

func _physics_process(delta: float) -> void:
	var gravity := ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) as float
	velocity.y = minf(velocity.y + gravity * gravity_scale * delta, max_fall_speed)
	move_and_slide()

func take_hit(damage: int, source: Node) -> void:
	var floors_lost: int = max(1, damage)
	current_floors = max(0, current_floors - floors_lost)
	if debug_print:
		print("[BuildingEnemy] hit by=%s floors=%d/%d" % [source.name, current_floors, max_floors])
	if current_floors <= 0:
		queue_free()
		return
	_rebuild_visual_and_collision()

func _rebuild_visual_and_collision() -> void:
	var total_h := current_floors * floor_height

	var shape := collision_shape.shape as RectangleShape2D
	shape.size = Vector2(floor_width, total_h)
	collision_shape.position = Vector2(0.0, -total_h * 0.5)

	# 층별로 색이 보이도록 세로 스트라이프 폴리곤 구성
	# (층 경계가 보이도록 10층 그라데이션)
	var points := PackedVector2Array([
		Vector2(-floor_width * 0.5, -total_h),
		Vector2(floor_width * 0.5, -total_h),
		Vector2(floor_width * 0.5, 0),
		Vector2(-floor_width * 0.5, 0)
	])
	body_visual.polygon = points
	body_visual.vertex_colors = _build_floor_vertex_colors(total_h)
	queue_redraw()

func _build_floor_vertex_colors(total_h: float) -> PackedColorArray:
	# Polygon2D vertex 4개만으로는 층별 색을 직접 나누기 어렵기 때문에
	# 층 경계 라인을 별도 draw로 처리한다.
	# 본체는 중간 톤 고정.
	return PackedColorArray([
		Color(0.70, 0.75, 0.82, 1.0),
		Color(0.70, 0.75, 0.82, 1.0),
		Color(0.60, 0.65, 0.72, 1.0),
		Color(0.60, 0.65, 0.72, 1.0)
	])

func _draw() -> void:
	# 층 경계선 + 층별 포인트 색으로 임시 시각 피드백 제공
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

	# 외곽선
	draw_rect(Rect2(Vector2(left, -total_h), Vector2(floor_width, total_h)), Color(0.1, 0.1, 0.14, 0.95), false, 2.0)
