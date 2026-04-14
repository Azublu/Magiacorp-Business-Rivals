extends Area2D
class_name Hitbox

@export var damage : float = 0.0
@export var knockback : float = 0.0
@export var knockback_dur : float = 0.0
@export var player_index : int = 0

func _init() -> void:
	collision_layer = 2
	collision_mask = 0
