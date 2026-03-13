extends Node

signal hit_confirmed(target: Node, damage: int)

@export var debug_print: bool = true
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.25
@export var attack_active_time: float = 0.08
@export var attack_offset: Vector2 = Vector2(0.0, -34.0)

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var hitbox: Area2D = $"../AttackHitbox"

var is_attacking: bool = false
var cooldown_left: float = 0.0
var active_left: float = 0.0
var _already_hit: Dictionary = {}
var _fallback_attack_prev: bool = false

func _ready() -> void:
	_validate_input_actions()
	hitbox.monitoring = false
	hitbox.body_entered.connect(_on_body_entered)
	hitbox.area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if cooldown_left > 0.0:
		cooldown_left = maxf(0.0, cooldown_left - delta)

	if is_attacking:
		active_left -= delta
		if active_left <= 0.0:
			_end_attack()

	var mobile_attack := false
	if player != null and player.has_method("consume_mobile_attack_request"):
		mobile_attack = bool(player.call("consume_mobile_attack_request"))
	
	if Input.is_action_just_pressed("attack") or _consume_fallback_attack_press() or mobile_attack:
		_try_start_attack()

func _try_start_attack() -> void:
	if is_attacking or cooldown_left > 0.0:
		return

	is_attacking = true
	active_left = attack_active_time
	cooldown_left = attack_cooldown
	_already_hit.clear()

	hitbox.position = attack_offset
	hitbox.monitoring = true

	# 이미 겹쳐 있는 대상도 첫 프레임에 놓치지 않도록 즉시 검사
	for body in hitbox.get_overlapping_bodies():
		_try_apply_hit(body)
	for area in hitbox.get_overlapping_areas():
		if area != hitbox:
			_try_apply_hit(area.get_parent())

	if debug_print:
		print("[Attack] start(upward)")

func _end_attack() -> void:
	is_attacking = false
	hitbox.monitoring = false

	if debug_print:
		print("[Attack] end")

func _on_body_entered(body: Node) -> void:
	_try_apply_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area == hitbox:
		return
	_try_apply_hit(area.get_parent())

func _try_apply_hit(target: Node) -> void:
	if target == null or target == player:
		return

	var id := target.get_instance_id()
	if _already_hit.has(id):
		return
	_already_hit[id] = true

	if target.has_method("take_hit"):
		target.call("take_hit", attack_damage, player)
		emit_signal("hit_confirmed", target, attack_damage)
		if debug_print:
			print("[Attack] hit target=%s damage=%d" % [target.name, attack_damage])
		return

	if target.is_in_group("hittable"):
		if debug_print:
			print("[Attack] hittable(no take_hit) target=%s" % target.name)

func is_attack_active() -> bool:
	return is_attacking

func _consume_fallback_attack_press() -> bool:
	var now_pressed := Input.is_physical_key_pressed(KEY_Z)
	var just_pressed := now_pressed and not _fallback_attack_prev
	_fallback_attack_prev = now_pressed
	return just_pressed

func _validate_input_actions() -> void:
	if not InputMap.has_action("attack"):
		push_warning("[PlayerAttack] Missing input action: attack")
