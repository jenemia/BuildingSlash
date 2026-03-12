extends CanvasLayer

@onready var hp_label: Label = $Panel/VBox/HPLabel
@onready var guard_label: Label = $Panel/VBox/GuardLabel
@onready var special_label: Label = $Panel/VBox/SpecialLabel
@onready var timer_label: Label = $Panel/VBox/TimerLabel
@onready var score_label: Label = $Panel/VBox/ScoreLabel

func update_stats(hp: int, max_hp: int, guard_current: float, guard_max: float, special_ratio: float, survival_sec: float, score: int) -> void:
	hp_label.text = "HP %d/%d" % [hp, max_hp]
	guard_label.text = "GUARD %d/%d" % [int(round(guard_current)), int(round(guard_max))]
	special_label.text = "SPECIAL %d%%" % int(round(clampf(special_ratio, 0.0, 1.0) * 100.0))
	timer_label.text = "TIME %.1fs" % survival_sec
	score_label.text = "SCORE %d" % score
