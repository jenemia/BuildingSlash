extends CharacterBody2D

@export var move_speed: float = 260.0
@export var accel: float = 1800.0
@export var decel: float = 2200.0
@export var jump_velocity: float = -420.0
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 980.0
@export var debug_print: bool = false

var is_grounded: bool = false
var facing: int = 1
var _debug_accum: float = 0.0

func _ready() -> void:
	_validate_input_actions()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	_apply_horizontal(input_dir, delta)
	_apply_vertical(delta)
	_try_jump()
	
	move_and_slide()
	
	is_grounded = is_on_floor()
	if input_dir != 0.0:
		facing = 1 if input_dir > 0.0 else -1
	
	_debug_tick(delta)

func _apply_horizontal(input_dir: float, delta: float) -> void:
	if input_dir != 0.0:
		velocity.x = move_toward(velocity.x, input_dir * move_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, decel * delta)

func _apply_vertical(delta: float) -> void:
	if not is_on_floor():
		var gravity := ProjectSettings.get_setting("physics/2d/default_gravity", 980.0) as float
		velocity.y += gravity * gravity_scale * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed

func _try_jump() -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _validate_input_actions() -> void:
	var required_actions := ["move_left", "move_right", "jump"]
	for action in required_actions:
		if not InputMap.has_action(action):
			push_warning("[PlayerController] Missing input action: %s" % action)

func _debug_tick(delta: float) -> void:
	if not debug_print:
		return
	
	_debug_accum += delta
	if _debug_accum >= 0.5:
		_debug_accum = 0.0
		print("[Player] vel=(%.1f, %.1f), grounded=%s" % [velocity.x, velocity.y, str(is_on_floor())])
