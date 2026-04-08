extends Control

@export_category("Player 1")
@export var player1_health : ProgressBar
@export var player1_damaged_health : ProgressBar
@export var player1_focus1 : ProgressBar
@export var player1_focus2 : ProgressBar
@export var player1_focus3 : ProgressBar
@export var player1_focus4 : ProgressBar
@export var player1_focus5 : ProgressBar

@export_category("Player 2")
@export var player2_health : ProgressBar
@export var player2_damaged_health: ProgressBar
@export var player2_focus1 : ProgressBar
@export var player2_focus2 : ProgressBar
@export var player2_focus3 : ProgressBar
@export var player2_focus4 : ProgressBar
@export var player2_focus5 : ProgressBar


func _ready() -> void:
	EventHandler.player_focus_changed.connect(update_focus)

func update_health(old_health : int, new_health : int, player_index : int) -> void:
	pass

func update_focus(focus_value : int, player_index : int) -> void:
	match player_index:
		1:
			pass
		2:
			pass
		_:
			print("Invalid Player Index")
