extends CanvasLayer

signal retry_pressed
signal go_lobby_pressed

@onready var panel: Panel = $Panel
@onready var summary_label: Label = $Panel/VBox/SummaryLabel

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$Panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	$Panel/VBox/Buttons/RetryButton.pressed.connect(func(): emit_signal("retry_pressed"))
	$Panel/VBox/Buttons/LobbyButton.pressed.connect(func(): emit_signal("go_lobby_pressed"))

func show_result(survival_sec: float, score: int, reward: int) -> void:
	visible = true
	summary_label.text = "생존 %.1fs\n점수 %d\n획득 재화 +%d" % [survival_sec, score, reward]

func hide_result() -> void:
	visible = false
