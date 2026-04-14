extends Area2D
class_name Hurtbox

@export var player_index : int

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", self._on_area_entered)

func _on_area_entered(hitbox: Hitbox) -> void:
	if hitbox == null: return

	#Prevents player2 from hurting self as long as hitboxes and hurtboxes are configured properly
	if player_index == hitbox.player_index: return
	#NOTE to self - Look into GODOT collision layers later, may be more efficient

	#This nested if statement decides what happens when a hit is detected
	if hitbox.name == "Hitbox":
		#Some scuffed math for a knockback on hit effect
		var knockback_dir = -(hitbox.owner.global_position - global_position).normalized()
		EventHandler.player_hit.emit(hitbox.damage,knockback_dir,hitbox.knockback,hitbox.knockback_dur,hitbox.player_index)
		
		##Deletes the node the colliding hitbox is attatched to if it has an on_hit function/method
		#if hitbox.owner.has_method("on_hit"):
			#hitbox.owner.on_hit()
