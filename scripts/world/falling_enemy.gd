extends CharacterBody2D

@export var max_hp: int = 3
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 920.0
@export var launch_up_force: float = 320.0
@export var launch_min_force: float = 120.0
@export var launch_max_force: float = 520.0
@export var launch_resistance: float = 0.35
@export var launch_cooldown: float = 0.08
@export var debug_print: bool = false

var hp: int
var _launch_cd_left: float = 0.0

@onready var visual: Polygon2D = $BodyVisual

func _ready() -> void:
	hp = max_hp
	add_to_group("hittable")
	_update_visual()

func _physics_process(delta: float) -> void:
	if _launch_cd_left > 0.0:
		_launch_cd_left = maxf(0.0, _launch_cd_left - delta)

	var gravity := ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) as float
	velocity.y += gravity * gravity_scale * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	move_and_slide()

func take_hit(damage: int, source: Node) -> void:
	hp = max(0, hp - max(1, damage))
	if debug_print:
		var source_name: String = "unknown" if source == null else String(source.name)
		print("[FallingEnemy] hit by=%s damage=%d hp=%d/%d" % [source_name, damage, hp, max_hp])
	_update_visual()
	if hp <= 0:
		queue_free()
		return

	_apply_launch(source)

func _apply_launch(source: Node = null) -> void:
	if _launch_cd_left > 0.0:
		return

	var force := launch_up_force * (1.0 - launch_resistance)
	force = clampf(force, launch_min_force, launch_max_force)
	velocity.y = minf(velocity.y, -force)
	# 밀착 충돌 상태에서도 공중 띄우기가 즉시 보이도록 미세 분리
	global_position.y -= 6.0
	_launch_cd_left = launch_cooldown

	if debug_print:
		var source_name: String = "unknown" if source == null else String(source.name)
		print("[FallingEnemy] launch by=%s force=%.1f vy=%.1f" % [source_name, force, velocity.y])

func _update_visual() -> void:
	if hp >= 2:
		visual.color = Color(0.35, 0.95, 0.45, 1.0)
	else:
		visual.color = Color(1.0, 0.45, 0.35, 1.0)
