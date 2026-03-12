extends Node

const RewardCalculator = preload("res://scripts/meta/reward_calculator.gd")

@export var max_hp: int = 100
@export var touch_damage: int = 18

@onready var root: Node2D = get_parent() as Node2D
@onready var player: Node = root.get_node("Player")
@onready var spawner: Node = root.get_node_or_null("EnemySpawner")
@onready var hud: CanvasLayer = root.get_node("CombatHUD")
@onready var result_panel: CanvasLayer = root.get_node("ResultPanel")
@onready var meta_menu: CanvasLayer = root.get_node("MetaMenu")
@onready var progression: Node = root.get_node("MetaProgression")

var hp: int
var score: int = 0
var survival_sec: float = 0.0
var is_run_active: bool = true

func _ready() -> void:
	hp = max_hp
	_connect_ui()
	_connect_world_events()
	_apply_progression_to_player()
	_update_hud()

func _process(delta: float) -> void:
	if not is_run_active:
		return
	survival_sec += delta
	_update_hud()

func _connect_ui() -> void:
	if result_panel.has_signal("retry_pressed"):
		result_panel.connect("retry_pressed", _on_retry_pressed)
	if result_panel.has_signal("open_meta_pressed"):
		result_panel.connect("open_meta_pressed", _on_open_meta_pressed)
	if meta_menu.has_signal("close_pressed"):
		meta_menu.connect("close_pressed", _on_close_meta_pressed)
	if meta_menu.has_signal("upgrade_requested"):
		meta_menu.connect("upgrade_requested", _on_upgrade_requested)
	if progression.has_signal("progression_changed"):
		progression.connect("progression_changed", _refresh_meta_menu)

func _connect_world_events() -> void:
	for block in get_tree().get_nodes_in_group("falling_block"):
		_register_block(block)
	get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node != null and node.is_in_group("falling_block"):
		_register_block(node)

func _register_block(block: Node) -> void:
	if block.has_signal("touched_player") and not block.is_connected("touched_player", _on_block_touched_player):
		block.connect("touched_player", _on_block_touched_player)
	if block.has_signal("block_broken") and not block.is_connected("block_broken", _on_block_broken):
		block.connect("block_broken", _on_block_broken)

func _on_block_touched_player(_target: Node) -> void:
	if not is_run_active:
		return
	var final_damage := float(touch_damage)
	if player.has_method("apply_incoming_damage"):
		final_damage = float(player.call("apply_incoming_damage", final_damage))
	hp = maxi(0, hp - int(ceil(final_damage)))
	_update_hud()
	if hp <= 0:
		_end_run()

func _on_block_broken(_block: Node, _tier: String, score_value: int) -> void:
	score += score_value
	_update_hud()

func _end_run() -> void:
	is_run_active = false
	if spawner != null:
		spawner.set_process(false)
	var reward := RewardCalculator.calculate_reward(survival_sec, score)
	progression.call("add_currency", reward)
	result_panel.call("show_result", survival_sec, score, reward)

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_open_meta_pressed() -> void:
	_refresh_meta_menu()
	meta_menu.call("show_menu", progression.get("currency"), progression.get("upgrades"), _costs())

func _on_close_meta_pressed() -> void:
	meta_menu.call("hide_menu")

func _on_upgrade_requested(key: String) -> void:
	var bought := bool(progression.call("try_buy_upgrade", key))
	if bought:
		_apply_progression_to_player()
	_refresh_meta_menu()

func _refresh_meta_menu() -> void:
	if meta_menu.visible:
		meta_menu.call("show_menu", progression.get("currency"), progression.get("upgrades"), _costs())

func _apply_progression_to_player() -> void:
	progression.call("apply_to_player", player)
	_update_hud()

func _costs() -> Dictionary:
	return {
		"attack": progression.call("get_upgrade_cost", "attack"),
		"jump": progression.call("get_upgrade_cost", "jump"),
		"guard": progression.call("get_upgrade_cost", "guard"),
		"special": progression.call("get_upgrade_cost", "special"),
	}

func _update_hud() -> void:
	if hud == null:
		return
	var guard_current := 0.0
	var guard_max := 0.0
	var special_ratio := 0.0
	if player != null:
		if player.has_method("get_guard_current"):
			guard_current = float(player.call("get_guard_current"))
		if player.has_method("get_guard_max"):
			guard_max = float(player.call("get_guard_max"))
		if player.has_method("get_special_ratio"):
			special_ratio = float(player.call("get_special_ratio"))
	hud.call("update_stats", hp, max_hp, guard_current, guard_max, special_ratio, survival_sec, score)
