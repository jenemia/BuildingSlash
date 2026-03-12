extends StaticBody2D

@export var max_hp: int = 5
@export var debug_print: bool = true

var hp: int

@onready var visual: Polygon2D = $BodyVisual

func _ready() -> void:
	hp = max_hp
	add_to_group("hittable")
	_update_visual()

func take_hit(damage: int, source: Node) -> void:
	hp = max(0, hp - max(1, damage))
	if debug_print:
		print("[DummyTarget] hit by=%s damage=%d hp=%d/%d" % [source.name, damage, hp, max_hp])
	_update_visual()
	if hp <= 0:
		queue_free()

func _update_visual() -> void:
	if hp >= int(max_hp * 0.6):
		visual.color = Color(0.4, 0.9, 0.4, 1.0)
	elif hp >= int(max_hp * 0.3):
		visual.color = Color(1.0, 0.75, 0.2, 1.0)
	else:
		visual.color = Color(1.0, 0.3, 0.3, 1.0)
