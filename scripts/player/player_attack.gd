extends Node

@export var debug_print: bool = true
@export var attack_damage: int = 1
@export var attack_cooldown: float = 0.25
@export var attack_active_time: float = 0.08
@export var attack_offset_x: float = 24.0

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var hitbox: Area2D = $"../AttackHitbox"

var is_attacking: bool = false
var cooldown_left: float = 0.0
var active_left: float = 0.0
var attack_facing: int = 1
var _already_hit: Dictionary = {}

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

	if Input.is_action_just_pressed("attack"):
		_try_start_attack()

func _try_start_attack() -> void:
	if is_attacking or cooldown_left > 0.0:
		return

	is_attacking = true
	active_left = attack_active_time
	cooldown_left = attack_cooldown
	_already_hit.clear()

	attack_facing = _get_player_facing()
	hitbox.position.x = attack_offset_x * attack_facing
	hitbox.monitoring = true

	if debug_print:
		print("[Attack] start facing=%d" % attack_facing)

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
		if debug_print:
			print("[Attack] hit target=%s damage=%d" % [target.name, attack_damage])
		return

	if target.is_in_group("hittable"):
		if debug_print:
			print("[Attack] hittable(no take_hit) target=%s" % target.name)

func _get_player_facing() -> int:
	if player != null and player.has_method("get_facing"):
		var value := int(player.call("get_facing"))
		return -1 if value < 0 else 1
	return 1

func _validate_input_actions() -> void:
	if not InputMap.has_action("attack"):
		push_warning("[PlayerAttack] Missing input action: attack")
