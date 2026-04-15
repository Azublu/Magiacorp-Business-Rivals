##NOTE: Tutorial Script: https://youtu.be/f-BtSwD-Cy4?si=QMw_dmCsoNEYDKvu
extends Control
class_name CharacterSelectionBox

@export var selectable = true
@export var character : CharacterResource

@onready var player_1_select: Panel = $Player1Select
@onready var player_2_select: Panel = $Player2Select

enum PlayerSelection {NONE, PLAYER1, PLAYER2}

var selected = false

func _ready() -> void:
	player_1_select.hide()
	player_2_select.hide()

func set_player_selection(player : PlayerSelection):
	if player == PlayerSelection.PLAYER1:
		selected = true
		player_1_select.show()
	if player == PlayerSelection.PLAYER2:
		selected = true
		player_2_select.show()

func get_character():
	return character

func reset():
	selected = false
	player_1_select.hide()
	player_2_select.hide()
