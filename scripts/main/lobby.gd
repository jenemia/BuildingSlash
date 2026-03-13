extends Node2D

@onready var meta_menu: CanvasLayer = $MetaMenu

func _ready() -> void:
	if MetaProgression.has_signal("progression_changed"):
		MetaProgression.progression_changed.connect(_refresh_meta_menu)
	meta_menu.show_menu(MetaProgression.currency, MetaProgression.upgrades, _costs())
	var close_button := meta_menu.get_node_or_null("Panel/VBox/CloseButton") as Button
	if close_button != null:
		close_button.text = "전투 시작"
	if meta_menu.has_signal("close_pressed"):
		meta_menu.close_pressed.connect(_on_start_battle_pressed)
	if meta_menu.has_signal("upgrade_requested"):
		meta_menu.upgrade_requested.connect(_on_upgrade_requested)

func _on_start_battle_pressed() -> void:
	SceneLoader.go_to_battle()

func _on_upgrade_requested(key: String) -> void:
	var bought := bool(MetaProgression.try_buy_upgrade(key))
	if bought:
		_refresh_meta_menu()

func _refresh_meta_menu() -> void:
	meta_menu.show_menu(MetaProgression.currency, MetaProgression.upgrades, _costs())

func _costs() -> Dictionary:
	return {
		"attack": MetaProgression.get_upgrade_cost("attack"),
		"jump": MetaProgression.get_upgrade_cost("jump"),
		"guard": MetaProgression.get_upgrade_cost("guard"),
		"special": MetaProgression.get_upgrade_cost("special"),
	}
