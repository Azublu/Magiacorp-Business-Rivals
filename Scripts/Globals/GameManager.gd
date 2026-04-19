extends Node

const TITLE_SCREEN = preload("uid://gxdj54sbrj1x")
const CHARACTER_SELECT = preload("uid://db10c4vkmbk8n")
const MAIN_GAME = preload("uid://bhd3pj64xixwa")

@export var player1 : Player
@export var player1Resource : CharacterResource
@export var player2 : Player
@export var player2Resource : CharacterResource

var p1wins : int = 0
var p2wins : int = 0

var game_camera : Camera2D

var game_finished : bool = false

enum Scenes {TITLE,CHAR_SELECT,BASIC_ARENA}

func change_scene(target_scene : Scenes) -> void:
	match target_scene:
		Scenes.TITLE:
			get_tree().change_scene_to_packed(TITLE_SCREEN)
		Scenes.CHAR_SELECT:
			get_tree().change_scene_to_packed(CHARACTER_SELECT)
		Scenes.BASIC_ARENA:
			get_tree().change_scene_to_packed(MAIN_GAME)
		_:
			print("Unable to find ", target_scene)

func game_over() -> void:
	if not game_finished:
		game_finished = true
	var tween = create_tween()
	tween.tween_property(Engine,"time_scale",0.3,1)
	tween.parallel().tween_property(game_camera,"zoom",Vector2(1.5,1.5),1)
	tween.tween_callback(return_to_char_select)
	

func return_to_char_select() -> void:
	Engine.time_scale = 1
	game_finished = false
	change_scene(Scenes.CHAR_SELECT)
