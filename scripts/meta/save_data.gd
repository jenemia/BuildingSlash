extends RefCounted
class_name SaveData

const SAVE_PATH := "user://save_data.json"

static func default_data() -> Dictionary:
	return {
		"currency": 0,
		"upgrades": {
			"attack": 0,
			"jump": 0,
			"guard": 0,
			"special": 0,
		}
	}

static func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return default_data()
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return default_data()
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return default_data()
	return _merge_defaults(parsed)

static func save_data(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveData] failed to open save path")
		return
	file.store_string(JSON.stringify(_merge_defaults(data), "\t"))

static func _merge_defaults(raw: Dictionary) -> Dictionary:
	var merged := default_data()
	merged["currency"] = int(raw.get("currency", merged["currency"]))
	var upgrades: Dictionary = merged["upgrades"]
	var incoming: Variant = raw.get("upgrades", {})
	if typeof(incoming) == TYPE_DICTIONARY:
		for key in upgrades.keys():
			upgrades[key] = int(incoming.get(key, upgrades[key]))
	merged["upgrades"] = upgrades
	return merged
