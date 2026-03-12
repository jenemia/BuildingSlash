extends Node

signal gauge_changed(current: float, max_value: float)
signal special_cast(cleared_count: int)

@export var max_special_gauge: float = 100.0
@export var special_cost: float = 100.0
@export var gain_per_hit: float = 18.0
@export var passive_gain_per_second: float = 2.0
@export var cast_cooldown: float = 0.75
@export var special_damage: int = 999
@export var debug_print: bool = false

var special_gauge: float = 0.0
var _cooldown_left: float = 0.0

@onready var player: CharacterBody2D = get_parent() as CharacterBody2D
@onready var attack_component: Node = get_node_or_null("../AttackComponent")

func _ready() -> void:
	_validate_input_actions()
	if attack_component != null and attack_component.has_signal("hit_confirmed"):
		attack_component.connect("hit_confirmed", _on_attack_hit_confirmed)
	_emit_gauge()

func _physics_process(delta: float) -> void:
	if _cooldown_left > 0.0:
		_cooldown_left = maxf(0.0, _cooldown_left - delta)

	if passive_gain_per_second > 0.0:
		add_gauge(passive_gain_per_second * delta)

	if Input.is_action_just_pressed("special"):
		_try_cast_special()

func add_gauge(amount: float) -> void:
	if amount <= 0.0:
		return
	special_gauge = clampf(special_gauge + amount, 0.0, max_special_gauge)
	_emit_gauge()

func can_cast_special() -> bool:
	return _cooldown_left <= 0.0 and special_gauge >= special_cost

func get_gauge_ratio() -> float:
	if max_special_gauge <= 0.0:
		return 0.0
	return clampf(special_gauge / max_special_gauge, 0.0, 1.0)

func _try_cast_special() -> void:
	if not can_cast_special():
		if debug_print:
			print("[Special] not ready gauge=%.1f/%.1f cd=%.2f" % [special_gauge, max_special_gauge, _cooldown_left])
		return

	special_gauge = maxf(0.0, special_gauge - special_cost)
	_cooldown_left = cast_cooldown
	_emit_gauge()

	var cleared_count := 0
	for n in get_tree().get_nodes_in_group("falling_block"):
		if n == null:
			continue
		if n.has_method("take_damage"):
			n.call("take_damage", special_damage, player)
			cleared_count += 1

	emit_signal("special_cast", cleared_count)
	if debug_print:
		print("[Special] cast cleared=%d" % cleared_count)

func _on_attack_hit_confirmed(_target: Node, damage: int) -> void:
	add_gauge(float(maxi(1, damage)) * gain_per_hit)

func _emit_gauge() -> void:
	emit_signal("gauge_changed", special_gauge, max_special_gauge)

func _validate_input_actions() -> void:
	if not InputMap.has_action("special"):
		push_warning("[PlayerSpecial] Missing input action: special")
