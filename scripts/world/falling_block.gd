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
@export var player_contact_cooldown: float = 0.30
@export var debug_print: bool = false
@export_enum("SOFT", "NORMAL", "HARD") var tier_name: String = "NORMAL"

signal hit_player(block: Node, player: Node)
signal reached_ground(block: Node, tier: String, ground_damage: int)
# Backward compatibility signals
signal touched_player(player: Node)
signal hit_ground(block: Node, tier: String, ground_damage: int)
signal block_broken(block: Node, tier: String, score_value: int)

var current_floors: int
var block_tier: int = BlockData.Tier.NORMAL
var max_hp: int = 1
var current_hp: int = 1
var score_value: int = 0
var ground_hit_damage: int = 8
var launch_resistance: float = 0.35
var _launch_cd_left: float = 0.0
var _ground_hit_processed: bool = false
var _last_player_hit_time_sec: float = -9999.0
var _color_top: Color = Color(0.93, 0.84, 0.58, 0.95)
var _color_bottom: Color = Color(0.82, 0.68, 0.34, 0.95)

func set_layout_floor_width(target_width: float) -> void:
	floor_width = maxf(72.0, target_width)
	if is_inside_tree():
		_rebuild_visual_and_collision()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_visual: Polygon2D = $BodyVisual
@onready var touch_sensor: Area2D = $TouchSensor
@onready var touch_sensor_shape: CollisionShape2D = $TouchSensor/CollisionShape2D

func _ready() -> void:
	current_floors = max_floors
	add_to_group("hittable")
	add_to_group("falling_block")
	if touch_sensor != null:
		if not touch_sensor.body_entered.is_connected(_on_touch_sensor_body_entered):
			touch_sensor.body_entered.connect(_on_touch_sensor_body_entered)
		_sync_touch_sensor_collision_mask()
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
		if _is_ground_collider(collider):
			_emit_ground_hit_once()
			queue_free()
			return
		if collider is Node and collider.is_in_group("player"):
			_emit_player_hit_once(collider, col.get_normal())

func set_block_tier(tier: int) -> void:
	block_tier = tier
	tier_name = BlockData.tier_to_name(block_tier)

	var config := BlockData.default_config_by_tier(block_tier)
	max_hp = int(config.get("max_hp", 1))
	current_hp = max_hp
	score_value = int(config.get("score_value", 0))
	ground_hit_damage = int(config.get("ground_hit_damage", 8))
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
	# 플레이어와 딱 붙은 상태에서 타격 시 분리되지 않으면 launch 체감이 죽으므로 약간 위로 분리.
	global_position.y -= 6.0
	_launch_cd_left = launch_cooldown

	if debug_print:
		var source_name: String = "unknown" if source == null else String(source.name)
		print("[FallingBlock] launch by=%s tier=%s force=%.1f vy=%.1f" % [source_name, tier_name, force, velocity.y])

func _is_ground_collider(collider: Variant) -> bool:
	if not (collider is Node):
		return false
	var node := collider as Node
	return node.name == "Ground" or node.is_in_group("ground")

func _emit_player_hit_once(player: Node, contact_normal: Vector2 = Vector2.UP) -> void:
	var now_sec := Time.get_ticks_msec() / 1000.0
	if now_sec - _last_player_hit_time_sec < player_contact_cooldown:
		return
	_last_player_hit_time_sec = now_sec

	emit_signal("hit_player", self, player)
	# Backward compatibility
	emit_signal("touched_player", player)

	_apply_launch(player)

	if player != null and player.has_method("request_contact_bounce"):
		var boosted := false
		if player.has_method("is_attack_timing"):
			boosted = bool(player.call("is_attack_timing"))
		player.call("request_contact_bounce", self, contact_normal, boosted)
	if debug_print and player != null:
		print("[FallingBlock] hit player=%s" % player.name)

func _emit_ground_hit_once() -> void:
	if _ground_hit_processed:
		return
	_ground_hit_processed = true
	emit_signal("reached_ground", self, tier_name, ground_hit_damage)
	# Backward compatibility
	emit_signal("hit_ground", self, tier_name, ground_hit_damage)
	if debug_print:
		print("[FallingBlock] reached ground tier=%s damage=%d" % [tier_name, ground_hit_damage])

func _on_touch_sensor_body_entered(body: Node) -> void:
	if body != null and body.is_in_group("player"):
		_emit_player_hit_once(body, Vector2.UP)

func _sync_touch_sensor_collision_mask() -> void:
	if touch_sensor == null:
		return
	var players := get_tree().get_nodes_in_group("player")
	if players.is_empty():
		return
	var p := players[0]
	if p is CollisionObject2D:
		touch_sensor.collision_mask = (p as CollisionObject2D).collision_layer

func _rebuild_visual_and_collision() -> void:
	var total_h := current_floors * floor_height
	
	if collision_shape == null:
		return
		
	# 충돌 히트박스는 월드 단위 고정(해상도 비의존)
	var shape := collision_shape.shape as RectangleShape2D
	shape.size = Vector2(floor_width, total_h)
	collision_shape.position = Vector2(0.0, -total_h * 0.5)
	if touch_sensor_shape != null and touch_sensor_shape.shape is RectangleShape2D:
		var sensor_rect := touch_sensor_shape.shape as RectangleShape2D
		sensor_rect.size = Vector2(floor_width, total_h)
		touch_sensor_shape.position = Vector2(0.0, -total_h * 0.5)

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
