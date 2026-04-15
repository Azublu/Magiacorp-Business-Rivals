##NOTE: Modified Tutorial Script: https://youtu.be/f-BtSwD-Cy4?si=QMw_dmCsoNEYDKvu
extends Control

@onready var player_1_character: TextureRect = %Player1Character
@onready var grid_container: GridContainer = %GridContainer
@onready var player_2_character: TextureRect = %Player2Character
@onready var player_1_label: Label = %Player1Label
@onready var player_2_label: Label = %Player2Label
@onready var player_1_ready: Label = %Player1Ready
@onready var player_2_ready: Label = %Player2Ready

var player1SelectionIndex : int = 0
var player2SelectionIndex : int = 0

var player1Character : CharacterResource
var player2Character : CharacterResource

func _ready() -> void:
	_refresh_selection()
	
func _refresh_selection() -> void:
	for child in grid_container.get_children():
		child.reset()
	
	var startContainerP1 = grid_container.get_child(player1SelectionIndex)
	var startContainerP2 = grid_container.get_child(player2SelectionIndex)
	
	startContainerP1.set_player_selection(CharacterSelectionBox.PlayerSelection.PLAYER1)
	player_1_character.texture = startContainerP1.get_character().texture
	player_1_label.text = startContainerP1.get_character().name
	
	startContainerP2.set_player_selection(CharacterSelectionBox.PlayerSelection.PLAYER2)
	player_2_character.texture = startContainerP2.get_character().texture
	player_2_label.text = startContainerP2.get_character().name

func _input(event: InputEvent) -> void:
	if not event.is_pressed(): return
	
	var player1Direction : Vector2i
	
	var P1xAxis = Input.get_joy_axis(0,JOY_AXIS_LEFT_X)
	if abs(P1xAxis) >= 1.0:
		player1Direction.x = roundi(P1xAxis)
	var P1yAxis = Input.get_joy_axis(0,JOY_AXIS_LEFT_Y)
	if abs(P1yAxis) >= 1.0:
		player1Direction.y = roundi(P1yAxis)
	
	var player2Direction : Vector2i
	
	var P2xAxis = Input.get_joy_axis(1,JOY_AXIS_LEFT_X)
	if abs(P2xAxis) >= 1.0:
		player2Direction.x = roundi(P2xAxis)
	var P2yAxis = Input.get_joy_axis(1,JOY_AXIS_LEFT_Y)
	if abs(P2yAxis) >= 1.0:
		player2Direction.y = roundi(P2yAxis)
	
	if not player1Character:
		player1SelectionIndex = _get_selection_index(player1SelectionIndex,player1Direction)
	
	if not player2Character:
		player2SelectionIndex = _get_selection_index(player2SelectionIndex,player2Direction)
	
	_refresh_selection()
	
	if Input.is_joy_button_pressed(0,JOY_BUTTON_B):
		player1Character = null
		player_1_ready.hide()
	if Input.is_joy_button_pressed(1,JOY_BUTTON_B):
		player2Character = null
		player_2_ready.hide()
	
	if Input.is_joy_button_pressed(0,JOY_BUTTON_A):
		player1Character = grid_container.get_child(player1SelectionIndex).get_character()
		player_1_ready.show()
	if Input.is_joy_button_pressed(1,JOY_BUTTON_A):
		player2Character = grid_container.get_child(player2SelectionIndex).get_character()
		player_2_ready.show()
	
	_check_selection_done()

func _get_selection_index(currentIndex : int, direction : Vector2):
	var index : int = currentIndex
	
	if direction.x:
		index = currentIndex + roundi(direction.x)
	
	if direction.y:
		index = currentIndex + roundi(direction.y) * grid_container.columns
	
	var max_index = grid_container.get_child_count() - 1
	index = clamp(index, 0, max_index)
	var selectedContainer = grid_container.get_child(index)
	if selectedContainer and selectedContainer.selectable:
		return index
	else:
		return currentIndex

func _check_selection_done():
	if player1Character and player2SelectionIndex:
		pass
		##TODO: Save seleciton in global script and change scenes
