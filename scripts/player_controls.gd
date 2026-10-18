class_name PlayerControls extends Resource

@export var player_index: int = 0
@export var move_up: String = "player1_move_up" 
@export var move_left: String = "player1_move_left"
@export var move_down: String = "player1_move_down"
@export var move_right: String = "player1_move_right"

func is_player_one() -> bool:
	if player_index == 0:
		return true
	
	return false

func is_player_two() -> bool:
	if player_index == 1:
		return true
	
	return false
