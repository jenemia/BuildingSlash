extends Node

const RewardCalculator = preload("res://scripts/meta/reward_calculator.gd")

@export var max_hp: int = 100
@export var hit_player_damage: int = 18
@export var reached_ground_damage_default: int = 8
@export var debug_damage_events: bool = false

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
var _damage_dedupe: Dictionary = {}

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
	if not get_tree().node_added.is_connected(_on_node_added):
		get_tree().node_added.connect(_on_node_added)

func _on_node_added(node: Node) -> void:
	if node == null:
		return
	# node_added 시점엔 block._ready()가 아직 실행 전이라 그룹이 비어 있을 수 있음.
	# 신호 보유 여부 기반으로 선등록하고, 그룹 조건은 deferred로 한 번 더 확인한다.
	if _looks_like_falling_block(node):
		_register_block(node)
		return
	call_deferred("_register_block_if_group_ready", node)

func _register_block_if_group_ready(node: Node) -> void:
	if node != null and node.is_in_group("falling_block"):
		_register_block(node)

func _looks_like_falling_block(node: Node) -> bool:
	return node.has_signal("hit_player") \
		or node.has_signal("reached_ground") \
		or node.has_signal("touched_player") \
		or node.has_signal("hit_ground")

func _register_block(block: Node) -> void:
	if block.has_signal("hit_player") and not block.is_connected("hit_player", _on_block_hit_player):
		block.connect("hit_player", _on_block_hit_player)
	elif block.has_signal("touched_player") and not block.is_connected("touched_player", _on_block_touched_player):
		# Backward compatibility
		block.connect("touched_player", _on_block_touched_player)

	if block.has_signal("reached_ground") and not block.is_connected("reached_ground", _on_block_reached_ground):
		block.connect("reached_ground", _on_block_reached_ground)
	elif block.has_signal("hit_ground") and not block.is_connected("hit_ground", _on_block_hit_ground):
		# Backward compatibility
		block.connect("hit_ground", _on_block_hit_ground)

	if block.has_signal("block_broken") and not block.is_connected("block_broken", _on_block_broken):
		block.connect("block_broken", _on_block_broken)

func _on_block_hit_player(block: Node, target: Node) -> void:
	if not is_run_active:
		return
	var final_damage := float(hit_player_damage)
	if target != null and target.has_method("apply_incoming_damage"):
		final_damage = float(target.call("apply_incoming_damage", final_damage))
	apply_damage({
		"source_type": "falling_block",
		"source_id": block.get_instance_id() if block != null else 0,
		"cause": "hit_player",
		"amount": int(ceil(final_damage)),
	})

func _on_block_touched_player(target: Node) -> void:
	# Backward compatibility path (older block signal payload)
	_on_block_hit_player(null, target)

func _on_block_reached_ground(block: Node, _tier: String, ground_damage: int) -> void:
	if not is_run_active:
		return
	var resolved_ground_damage := ground_damage
	if resolved_ground_damage <= 0:
		resolved_ground_damage = reached_ground_damage_default
	resolved_ground_damage = maxi(1, resolved_ground_damage)
	apply_damage({
		"source_type": "falling_block",
		"source_id": block.get_instance_id() if block != null else 0,
		"cause": "reached_ground",
		"amount": resolved_ground_damage,
	})

func _on_block_hit_ground(block: Node, tier: String, ground_damage: int) -> void:
	# Backward compatibility path
	_on_block_reached_ground(block, tier, ground_damage)

func apply_damage(event: Dictionary) -> void:
	if not is_run_active:
		return
	var source_id := int(event.get("source_id", 0))
	var cause := String(event.get("cause", "unknown"))
	var amount := maxi(1, int(event.get("amount", 1)))
	var dedupe_key := "%s:%s" % [str(source_id), cause]
	if source_id != 0 and _damage_dedupe.has(dedupe_key):
		return
	if source_id != 0:
		_damage_dedupe[dedupe_key] = true

	hp = maxi(0, hp - amount)
	if debug_damage_events:
		print("[GameFlow] damage source=%s id=%d cause=%s amount=%d hp=%d/%d" % [String(event.get("source_type", "unknown")), source_id, cause, amount, hp, max_hp])
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
