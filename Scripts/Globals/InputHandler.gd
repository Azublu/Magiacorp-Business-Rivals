extends Node

##NOTE: Singleton pattern designated through engine in 
##Project > Project Settings > Globals

func get_horizontal_input(player_index : int) -> float:
	if player_index != -1:
		return Input.get_joy_axis(player_index,JOY_AXIS_LEFT_X)
	else:
		return Input.get_axis("p1_left","p1_right")
	
func get_vertical_input(player_index : int = -1) -> float:
	return Input.get_joy_axis(player_index,JOY_AXIS_LEFT_Y)

func get_jump_input(player_index:int = -1) -> bool:
	return Input.is_joy_button_pressed(player_index,JOY_BUTTON_A)

func get_dash_input(player_index : int = -1) -> float:
	return Input.get_joy_axis(player_index, JOY_AXIS_TRIGGER_LEFT)

func get_attack_input(player_index: int = -1) -> bool:
	return Input.is_joy_button_pressed(player_index,JOY_BUTTON_X)

func get_block_input(player_index: int = -1) -> bool:
	return Input.is_joy_button_pressed(player_index,JOY_BUTTON_LEFT_SHOULDER)
