extends CharacterBody2D

const BlockData = preload("res://scripts/world/block_data.gd")

@export var max_floors: int = 10
@export var floor_height: float = 28.0
@export var floor_width: float = 180.0
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 520.0
@export var despawn_margin: float = 220.0
@export var debug_print: bool = false
@export_enum("SOFT", "NORMAL", "HARD") var tier_name: String = "NORMAL"

signal touched_player(player: Node)
signal block_broken(block: Node, tier: String, score_value: int)

var current_floors: int
var block_tier: int = BlockData.Tier.NORMAL
var max_hp: int = 1
var current_hp: int = 1
var score_value: int = 0
var _color_top: Color = Color(0.93, 0.84, 0.58, 0.95)
var _color_bottom: Color = Color(0.82, 0.68, 0.34, 0.95)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_visual: Polygon2D = $BodyVisual

func _ready() -> void:
	current_floors = max_floors
	add_to_group("hittable")
	add_to_group("falling_block")
	set_block_tier(BlockData.tier_from_name(tier_name))

func _physics_process(delta: float) -> void:
	var gravity := ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) as float
	velocity.y = minf(velocity.y + gravity * gravity_scale * delta, max_fall_speed)
	move_and_slide()

	var viewport_bottom := get_viewport_rect().size.y
	if global_position.y > viewport_bottom + despawn_margin:
		if debug_print:
			print("[FallingBlock] despawned out-of-bounds y=%.1f (viewport=%.1f)" % [global_position.y, viewport_bottom])
		queue_free()
		return

	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		if col == null:
			continue
		var collider := col.get_collider()
		if collider is Node and collider.is_in_group("player"):
			emit_signal("touched_player", collider)
			if collider.has_method("request_contact_bounce"):
				var boosted := false
				if collider.has_method("is_attack_timing"):
					boosted = bool(collider.call("is_attack_timing"))
				collider.call("request_contact_bounce", self, col.get_normal(), boosted)
			if debug_print:
				print("[FallingBlock] touched player=%s" % collider.name)

func set_block_tier(tier: int) -> void:
	block_tier = tier
	tier_name = BlockData.tier_to_name(block_tier)

	var config := BlockData.default_config_by_tier(block_tier)
	max_hp = int(config.get("max_hp", 1))
	current_hp = max_hp
	score_value = int(config.get("score_value", 0))
	_color_top = config.get("color_top", Color.WHITE)
	_color_bottom = config.get("color_bottom", Color.GRAY)

	_rebuild_visual_and_collision()
	if debug_print:
		print("[FallingBlock] tier=%s hp=%d score=%d" % [tier_name, current_hp, score_value])

func take_damage(amount: int, source: Node = null) -> void:
	var dmg: int = maxi(1, amount)
	current_hp = maxi(0, current_hp - dmg)

	if debug_print:
		var source_name: String = "unknown" if source == null else String(source.name)
		print("[FallingBlock] damage by=%s tier=%s hp=%d/%d" % [source_name, tier_name, current_hp, max_hp])

	if current_hp <= 0:
		break_block()
		return

	current_floors = max(1, int(round((float(current_hp) / float(max_hp)) * float(max_floors))))
	_rebuild_visual_and_collision()

func take_hit(damage: int, source: Node) -> void:
	# T02 호환용 별칭: 기존 공격 스크립트가 take_hit를 호출한다.
	take_damage(damage, source)

func break_block() -> void:
	emit_signal("block_broken", self, tier_name, score_value)
	queue_free()

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
	body_visual.vertex_colors = PackedColorArray([
		_color_top,
		_color_top,
		_color_bottom,
		_color_bottom,
	])
	queue_redraw()

func _draw() -> void:
	var total_h := current_floors * floor_height
	var left := -floor_width * 0.5
	var right := floor_width * 0.5

	for i in range(current_floors):
		var y_top := -total_h + i * floor_height
		var y_bottom := y_top + floor_height
		var t := float(i) / maxf(1.0, float(max_floors - 1))
		var floor_color := _color_top.lerp(_color_bottom, t)
		draw_rect(Rect2(Vector2(left, y_top), Vector2(floor_width, floor_height - 1.0)), floor_color, true)
		draw_line(Vector2(left, y_bottom), Vector2(right, y_bottom), Color(0.10, 0.10, 0.14, 0.78), 1.5)

	draw_rect(Rect2(Vector2(left, -total_h), Vector2(floor_width, total_h)), Color(0.1, 0.1, 0.14, 0.95), false, 2.0)
