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
var mobile_axis: float = 0.0
var mobile_jump_requested: bool = false
var _debug_accum: float = 0.0

func _ready() -> void:
	_validate_input_actions()

func _physics_process(delta: float) -> void:
	var input_dir := _read_move_axis()
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
	var jump_pressed := Input.is_action_just_pressed("jump") or mobile_jump_requested
	if jump_pressed and is_on_floor():
		velocity.y = jump_velocity
	mobile_jump_requested = false

func _read_move_axis() -> float:
	var axis := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(axis):
		return axis

	# Fallback: 방향키 직접 입력 (초기 프로토타입 안정성 목적)
	var fallback := 0.0
	if Input.is_key_pressed(KEY_LEFT):
		fallback -= 1.0
	if Input.is_key_pressed(KEY_RIGHT):
		fallback += 1.0
	if not is_zero_approx(fallback):
		return fallback

	return clampf(mobile_axis, -1.0, 1.0)

func set_mobile_move_axis(axis: float) -> void:
	mobile_axis = clampf(axis, -1.0, 1.0)

func trigger_mobile_jump() -> void:
	mobile_jump_requested = true

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
