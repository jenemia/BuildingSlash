extends CanvasLayer

signal close_pressed
signal upgrade_requested(key: String)

@onready var currency_label: Label = $Panel/VBox/CurrencyLabel
@onready var attack_btn: Button = $Panel/VBox/Buttons/AttackBtn
@onready var jump_btn: Button = $Panel/VBox/Buttons/JumpBtn
@onready var guard_btn: Button = $Panel/VBox/Buttons/GuardBtn
@onready var special_btn: Button = $Panel/VBox/Buttons/SpecialBtn

func _ready() -> void:
	visible = false
	$Panel/VBox/CloseButton.pressed.connect(func(): emit_signal("close_pressed"))
	attack_btn.pressed.connect(func(): emit_signal("upgrade_requested", "attack"))
	jump_btn.pressed.connect(func(): emit_signal("upgrade_requested", "jump"))
	guard_btn.pressed.connect(func(): emit_signal("upgrade_requested", "guard"))
	special_btn.pressed.connect(func(): emit_signal("upgrade_requested", "special"))

func show_menu(currency: int, upgrades: Dictionary, costs: Dictionary) -> void:
	visible = true
	currency_label.text = "재화: %d" % currency
	attack_btn.text = "공격 Lv.%d (비용 %d)" % [int(upgrades.get("attack", 0)), int(costs.get("attack", 0))]
	jump_btn.text = "점프 Lv.%d (비용 %d)" % [int(upgrades.get("jump", 0)), int(costs.get("jump", 0))]
	guard_btn.text = "방어 Lv.%d (비용 %d)" % [int(upgrades.get("guard", 0)), int(costs.get("guard", 0))]
	special_btn.text = "필살 Lv.%d (비용 %d)" % [int(upgrades.get("special", 0)), int(costs.get("special", 0))]

func hide_menu() -> void:
	visible = false
