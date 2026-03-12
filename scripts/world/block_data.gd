extends RefCounted
class_name BlockData

enum Tier {
	SOFT,
	NORMAL,
	HARD,
}

static func default_config_by_tier(tier: Tier) -> Dictionary:
	match tier:
		Tier.SOFT:
			return {
				"label": "SOFT",
				"max_hp": 2,
				"score_value": 10,
				"ground_hit_damage": 4,
				"launch_resistance": 0.10,
				"color_top": Color(0.56, 0.93, 0.83, 0.95),
				"color_bottom": Color(0.33, 0.83, 0.72, 0.95),
			}
		Tier.HARD:
			return {
				"label": "HARD",
				"max_hp": 6,
				"score_value": 30,
				"ground_hit_damage": 12,
				"launch_resistance": 0.60,
				"color_top": Color(0.53, 0.57, 0.66, 0.98),
				"color_bottom": Color(0.30, 0.33, 0.41, 0.98),
			}
		_:
			return {
				"label": "NORMAL",
				"max_hp": 4,
				"score_value": 20,
				"ground_hit_damage": 8,
				"launch_resistance": 0.35,
				"color_top": Color(0.93, 0.84, 0.58, 0.95),
				"color_bottom": Color(0.82, 0.68, 0.34, 0.95),
			}

static func tier_from_name(value: String) -> Tier:
	match value.to_upper():
		"SOFT":
			return Tier.SOFT
		"HARD":
			return Tier.HARD
		_:
			return Tier.NORMAL

static func tier_to_name(tier: Tier) -> String:
	match tier:
		Tier.SOFT:
			return "SOFT"
		Tier.HARD:
			return "HARD"
		_:
			return "NORMAL"
