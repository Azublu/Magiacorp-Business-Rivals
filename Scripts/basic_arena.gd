extends Node2D

@export var player1pos : Marker2D
@export var player2pos : Marker2D
@export var player1outline : Resource
@export var player2outline : Resource
@export var game_camera: GameCamera

func _ready() -> void:
	var player1 = GameManager.player1Resource.Character.instantiate()
	player1.global_position = player1pos.global_position
	player1.player_index = 0
	player1.material = player1outline
	
	var player2 = GameManager.player2Resource.Character.instantiate()
	player2.global_position = player2pos.global_position
	player2.player_index = 1
	player2.material = player2outline
	
	add_child(player1)
	add_child(player2)
	
	game_camera.init_players(player1,player2)
