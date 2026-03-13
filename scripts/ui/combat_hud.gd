extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var hp_label: Label = $Panel/VBox/HPLabel
@onready var guard_label: Label = $Panel/VBox/GuardLabel
@onready var special_label: Label = $Panel/VBox/SpecialLabel
@onready var timer_label: Label = $Panel/VBox/TimerLabel
@onready var score_label: Label = $Panel/VBox/ScoreLabel

@export var panel_margin_left: float = 16.0
@export var panel_margin_top: float = 16.0

func apply_safe_area(safe_rect: Rect2) -> void:
	if panel == null:
		return
	panel.position = Vector2(safe_rect.position.x + panel_margin_left, safe_rect.position.y + panel_margin_top)

func update_stats(hp: int, max_hp: int, guard_current: float, guard_max: float, special_ratio: float, survival_sec: float, score: int) -> void:
	hp_label.text = "HP %d/%d" % [hp, max_hp]
	guard_label.text = "GUARD %d/%d" % [int(round(guard_current)), int(round(guard_max))]
	special_label.text = "SPECIAL %d%%" % int(round(clampf(special_ratio, 0.0, 1.0) * 100.0))
	timer_label.text = "TIME %.1fs" % survival_sec
	score_label.text = "SCORE %d" % score