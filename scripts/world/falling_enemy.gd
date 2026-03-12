extends CharacterBody2D

@export var max_hp: int = 3
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 920.0
@export var debug_print: bool = false

var hp: int

@onready var visual: Polygon2D = $BodyVisual

func _ready() -> void:
	hp = max_hp
	add_to_group("hittable")
	_update_visual()

func _physics_process(delta: float) -> void:
	var gravity := ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) as float
	velocity.y += gravity * gravity_scale * delta
	velocity.y = minf(velocity.y, max_fall_speed)
	move_and_slide()

func take_hit(damage: int, source: Node) -> void:
	hp = max(0, hp - max(1, damage))
	if debug_print:
		print("[FallingEnemy] hit by=%s damage=%d hp=%d/%d" % [source.name, damage, hp, max_hp])
	_update_visual()
	if hp <= 0:
		queue_free()

func _update_visual() -> void:
	if hp >= 2:
		visual.color = Color(0.35, 0.95, 0.45, 1.0)
	else:
		visual.color = Color(1.0, 0.45, 0.35, 1.0)
