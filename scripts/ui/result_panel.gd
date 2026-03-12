extends CanvasLayer

signal retry_pressed
signal open_meta_pressed

@onready var panel: Panel = $Panel
@onready var summary_label: Label = $Panel/VBox/SummaryLabel

func _ready() -> void:
	visible = false
	$Panel/VBox/Buttons/RetryButton.pressed.connect(func(): emit_signal("retry_pressed"))
	$Panel/VBox/Buttons/MetaButton.pressed.connect(func(): emit_signal("open_meta_pressed"))

func show_result(survival_sec: float, score: int, reward: int) -> void:
	visible = true
	summary_label.text = "생존 %.1fs\n점수 %d\n획득 재화 +%d" % [survival_sec, score, reward]

func hide_result() -> void:
	visible = false
