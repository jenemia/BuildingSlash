extends Node

const LOBBY_SCENE_PATH := "res://scenes/Lobby.tscn"
const BATTLE_SCENE_PATH := "res://scenes/Main.tscn"

var _is_changing_scene: bool = false

func go_to_lobby() -> void:
	_change_scene(LOBBY_SCENE_PATH)

func go_to_battle() -> void:
	_change_scene(BATTLE_SCENE_PATH)

func reload_current_scene() -> void:
	if _is_changing_scene:
		return
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _change_scene(path: String) -> void:
	if _is_changing_scene:
		return
	_is_changing_scene = true
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(path)
	_is_changing_scene = false
