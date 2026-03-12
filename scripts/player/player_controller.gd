extends CharacterBody2D

@export var move_speed: float = 260.0
@export var accel: float = 1800.0
@export var decel: float = 2200.0
@export var jump_velocity: float = -420.0
@export var gravity_scale: float = 1.0
@export var max_fall_speed: float = 980.0
@export var debug_print: bool = false
@export var contact_bounce_velocity: float = 360.0
@export var contact_bounce_attack_bonus: float = 120.0
@export var contact_bounce_cooldown: float = 0.12

var is_grounded: bool = false
var facing: int = 1
var mobile_axis: float = 0.0
var mobile_jump_requested: bool = false
var mobile_attack_requested: bool = false
var mobile_guard_pressed: bool = false
var _debug_accum: float = 0.0
var _bounce_cd_left: float = 0.0

@onready var guard_component: Node = $GuardComponent
@onready var attack_component: Node = $AttackComponent
@onready var body_visual: CanvasItem = $BodyVisual

func _ready() -> void:
	add_to_group("player")
	_validate_input_actions()

func _physics_process(delta: float) -> void:
	var input_dir := _read_move_axis()
	_apply_horizontal(input_dir, delta)
	_apply_vertical(delta)
	_try_jump()
	_update_guard(delta)
	if _bounce_cd_left > 0.0:
		_bounce_cd_left = maxf(0.0, _bounce_cd_left - delta)
	
	move_and_slide()
	
	is_grounded = is_on_floor()
	if input_dir != 0.0:
		facing = 1 if input_dir > 0.0 else -1
	
	_update_guard_visual()
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

func _update_guard(delta: float) -> void:
	if guard_component == null:
		return
	
	var guard_pressed := Input.is_action_pressed("guard") or mobile_guard_pressed
	guard_component.call("update_guard", delta, guard_pressed, true)
	mobile_guard_pressed = false

func _update_guard_visual() -> void:
	if body_visual == null:
		return
	if is_guarding():
		body_visual.modulate = Color(0.65, 0.8, 1.0, 1.0)
	else:
		body_visual.modulate = Color(1.0, 1.0, 1.0, 1.0)

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

func trigger_mobile_attack() -> void:
	mobile_attack_requested = true

func set_mobile_guard_pressed(pressed: bool) -> void:
	mobile_guard_pressed = pressed

func consume_mobile_attack_request() -> bool:
	if mobile_attack_requested:
		mobile_attack_requested = false
		return true
	return false

func get_facing() -> int:
	return facing

func is_guarding() -> bool:
	if guard_component == null:
		return false
	return bool(guard_component.get("is_guarding"))

func get_guard_current() -> float:
	if guard_component == null:
		return 0.0
	return float(guard_component.get("guard_current"))

func get_guard_max() -> float:
	if guard_component == null:
		return 0.0
	return float(guard_component.get("guard_max"))

func get_guard_ratio() -> float:
	if guard_component == null:
		return 0.0
	return float(guard_component.call("get_guard_ratio"))

func apply_incoming_damage(base_damage: float) -> float:
	if guard_component == null:
		return base_damage
	var final_damage := base_damage * float(guard_component.call("get_damage_multiplier"))
	if debug_print:
		print("[Damage] base=%.2f final=%.2f guarding=%s" % [base_damage, final_damage, str(is_guarding())])
	return final_damage

func is_attack_timing() -> bool:
	if attack_component == null:
		return false
	if attack_component.has_method("is_attack_active"):
		return bool(attack_component.call("is_attack_active"))
	return false

func request_contact_bounce(source: Node = null, normal: Vector2 = Vector2.UP, force_attack_bonus: bool = false) -> bool:
	if _bounce_cd_left > 0.0:
		return false

	var airborne := not is_on_floor()
	var attack_timing := force_attack_bonus or is_attack_timing()
	if not airborne and not attack_timing:
		return false

	var bounce_strength := contact_bounce_velocity
	if attack_timing:
		bounce_strength += contact_bounce_attack_bonus

	# normal 반대 방향으로 튕기되, 본 요청의 핵심은 상향 반발력이므로 최소 위쪽 속도를 보장한다.
	var up_bounce := -absf(bounce_strength * maxf(0.5, -normal.y))
	velocity.y = minf(velocity.y, up_bounce)
	_bounce_cd_left = contact_bounce_cooldown

	if debug_print:
		var source_name := "unknown" if source == null else source.name
		print("[Bounce] source=%s attack_timing=%s vy=%.1f" % [source_name, str(attack_timing), velocity.y])

	return true

func _validate_input_actions() -> void:
	var required_actions := ["move_left", "move_right", "jump", "guard"]
	for action in required_actions:
		if not InputMap.has_action(action):
			push_warning("[PlayerController] Missing input action: %s" % action)

func _debug_tick(delta: float) -> void:
	if not debug_print:
		return
	
	_debug_accum += delta
	if _debug_accum >= 0.5:
		_debug_accum = 0.0
		print("[Player] vel=(%.1f, %.1f), grounded=%s, guard=%.1f/%0.1f" % [velocity.x, velocity.y, str(is_on_floor()), get_guard_current(), get_guard_max()])
