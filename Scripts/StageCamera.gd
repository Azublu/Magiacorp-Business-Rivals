extends Camera2D

@export var player1 : Node2D
@export var player2 : Node2D
@export var min_zoom : float = 0.45
@export var max_zoom : float = 2.0
@export var margin : Vector2 = Vector2(100,100)

func _process(delta: float) -> void:
	if not player1 or not player2: return
	
	var target_pos = (player1.position + player2.position)/2
	position = target_pos
	
	var distance = player1.position.distance_to(player2.position)
	var new_zoom = clamp(1.0/(distance/500),min_zoom,max_zoom)
	zoom = Vector2(new_zoom,new_zoom)
