extends Node

signal guard_changed(current: float, max_value: float, guarding: bool)

@export var guard_max: float = 100.0
@export var guard_current: float = 100.0
@export var guard_drain_per_second: float = 30.0
@export var guard_recover_per_second: float = 20.0
@export var guard_damage_multiplier: float = 0.35
@export var min_guard_to_activate: float = 5.0

var is_guarding: bool = false

func _ready() -> void:
	guard_current = clampf(guard_current, 0.0, guard_max)
	_emit_changed()

func update_guard(delta: float, wants_guard: bool, can_guard: bool = true) -> void:
	var prev_guarding := is_guarding

	if wants_guard and can_guard and guard_current >= min_guard_to_activate:
		is_guarding = true
		guard_current = maxf(0.0, guard_current - guard_drain_per_second * delta)
		if guard_current <= 0.0:
			is_guarding = false
	else:
		is_guarding = false
		guard_current = minf(guard_max, guard_current + guard_recover_per_second * delta)

	if prev_guarding != is_guarding:
		_emit_changed()
		return

	_emit_changed()

func get_guard_ratio() -> float:
	if guard_max <= 0.0:
		return 0.0
	return clampf(guard_current / guard_max, 0.0, 1.0)

func get_damage_multiplier() -> float:
	if is_guarding:
		return guard_damage_multiplier
	return 1.0

func _emit_changed() -> void:
	emit_signal("guard_changed", guard_current, guard_max, is_guarding)
