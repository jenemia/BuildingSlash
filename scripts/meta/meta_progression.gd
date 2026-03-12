extends Node

signal progression_changed

const SaveDataRef = preload("res://scripts/meta/save_data.gd")

var currency: int = 0
var upgrades := {
	"attack": 0,
	"jump": 0,
	"guard": 0,
	"special": 0,
}

func _ready() -> void:
	load_progression()

func load_progression() -> void:
	var data := SaveDataRef.load_data()
	currency = int(data.get("currency", 0))
	var raw_upgrades: Dictionary = data.get("upgrades", {})
	for key in upgrades.keys():
		upgrades[key] = int(raw_upgrades.get(key, 0))
	emit_signal("progression_changed")

func save_progression() -> void:
	SaveDataRef.save_data({
		"currency": currency,
		"upgrades": upgrades,
	})

func add_currency(amount: int) -> void:
	currency = maxi(0, currency + amount)
	save_progression()
	emit_signal("progression_changed")

func get_upgrade_cost(key: String) -> int:
	var level := int(upgrades.get(key, 0))
	return 30 + (level * 20)

func try_buy_upgrade(key: String) -> bool:
	if not upgrades.has(key):
		return false
	var cost := get_upgrade_cost(key)
	if currency < cost:
		return false
	currency -= cost
	upgrades[key] = int(upgrades[key]) + 1
	save_progression()
	emit_signal("progression_changed")
	return true

func apply_to_player(player: Node) -> void:
	if player == null:
		return

	# 공격력 증가
	var attack_component: Node = player.get_node_or_null("AttackComponent")
	if attack_component != null:
		attack_component.set("attack_damage", 1 + int(upgrades.get("attack", 0)))

	# 점프 강화
	player.set("jump_velocity", -420.0 - float(int(upgrades.get("jump", 0)) * 24))

	# 가드 게이지 최대치 강화
	var guard_component: Node = player.get_node_or_null("GuardComponent")
	if guard_component != null:
		guard_component.set("guard_max", 100.0 + float(int(upgrades.get("guard", 0)) * 20))
		guard_component.set("guard_current", guard_component.get("guard_max"))

	# 필살기 충전 효율 강화
	var special_component: Node = player.get_node_or_null("SpecialComponent")
	if special_component != null:
		special_component.set("gain_per_hit", 18.0 + float(int(upgrades.get("special", 0)) * 3))
