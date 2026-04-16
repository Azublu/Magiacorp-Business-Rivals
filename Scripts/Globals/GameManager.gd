extends Node

const TITLE_SCREEN = preload("uid://gxdj54sbrj1x")
const CHARACTER_SELECT = preload("uid://db10c4vkmbk8n")

@export var player1 : Player
@export var player2 : Player

func change_scene(target_scene : String) -> void:
	match target_scene:
		"TITLE":
			get_tree().change_scene_to_packed(TITLE_SCREEN)
		"CHAR_SELECT":
			get_tree().change_scene_to_packed(CHARACTER_SELECT)
		_:
			print("Unable to find ", target_scene)
