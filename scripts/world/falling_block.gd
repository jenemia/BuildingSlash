extends CharacterBody2D

const BlockData = preload("res://scripts/world/block_data.gd")

@export var max_floors: int = 10
@export var floor_height: float = 28.0
@export var floor_width: float = 180.0
@export var visual_size_scale: float = 1.25
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 520.0
@export var despawn_margin: float = 220.0
@export var launch_up_force: float = 320.0
@export var launch_min_force: float = 120.0
@export var launch_max_force: float = 520.0
@export var launch_cooldown: float = 0.08
@export var debug_print: bool = false
@export_enum("SOFT", "NORMAL", "HARD") var tier_name: String = "NORMAL"

signal touched_player(player: Node)
signal block_broken(block: Node, tier: String, score_value: int)

var current_floors: int
var block_tier: int = BlockData.Tier.NORMAL
var max_hp: int = 1
var current_hp: int = 1
var score_value: int = 0
var launch_resistance: float = 0.35
var _launch_cd_left: float = 0.0
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
	if _launch_cd_left > 0.0:
		_launch_cd_left = maxf(0.0, _launch_cd_left - delta)

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
	launch_resistance = clampf(float(config.get("launch_resistance", 0.35)), 0.0, 0.95)
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
	if current_hp > 0:
		_apply_launch(source)

func break_block() -> void:
	emit_signal("block_broken", self, tier_name, score_value)
	queue_free()

func _apply_launch(source: Node = null) -> void:
	if _launch_cd_left > 0.0:
		return

	var force := launch_up_force * (1.0 - launch_resistance)
	force = clampf(force, launch_min_force, launch_max_force)
	velocity.y = minf(velocity.y, -force)
	_launch_cd_left = launch_cooldown

	if debug_print:
		var source_name: String = "unknown" if source == null else String(source.name)
		print("[FallingBlock] launch by=%s tier=%s force=%.1f vy=%.1f" % [source_name, tier_name, force, velocity.y])

func _rebuild_visual_and_collision() -> void:
	var total_h := current_floors * floor_height

	# 충돌 히트박스는 월드 단위 고정(해상도 비의존)
	var shape := collision_shape.shape as RectangleShape2D
	shape.size = Vector2(floor_width, total_h)
	collision_shape.position = Vector2(0.0, -total_h * 0.5)

	# 비주얼만 크기 조정
	var visual_w := floor_width * visual_size_scale
	var visual_h := total_h * visual_size_scale
	var points := PackedVector2Array([
		Vector2(-visual_w * 0.5, -visual_h),
		Vector2(visual_w * 0.5, -visual_h),
		Vector2(visual_w * 0.5, 0),
		Vector2(-visual_w * 0.5, 0)
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
	var visual_w := floor_width * visual_size_scale
	var visual_h := total_h * visual_size_scale
	var visual_floor_h := floor_height * visual_size_scale
	var left := -visual_w * 0.5
	var right := visual_w * 0.5

	for i in range(current_floors):
		var y_top := -visual_h + i * visual_floor_h
		var y_bottom := y_top + visual_floor_h
		var t := float(i) / maxf(1.0, float(max_floors - 1))
		var floor_color := _color_top.lerp(_color_bottom, t)
		draw_rect(Rect2(Vector2(left, y_top), Vector2(visual_w, visual_floor_h - 1.0)), floor_color, true)
		draw_line(Vector2(left, y_bottom), Vector2(right, y_bottom), Color(0.10, 0.10, 0.14, 0.78), 1.5)

	draw_rect(Rect2(Vector2(left, -visual_h), Vector2(visual_w, visual_h)), Color(0.1, 0.1, 0.14, 0.95), false, 2.0)
