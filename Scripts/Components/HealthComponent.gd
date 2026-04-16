extends Node
class_name HealthComponent

@export var focus_regen_timer : Timer

var player_index

var max_health : int = 1000
var max_focus : int = 100

var health : int = 1000:
	set(value):
		health = clamp(value,0,max_health)
		update_health(health)
		if health <= 0:
			pass
var focus : int = 100:
	set(value):
		focus = clamp(value,-10,max_focus)
		update_focus(focus)

func _init() -> void:
	EventHandler.player_hit.connect(player_hit)
	EventHandler.player_blocked.connect(player_blocked)

func _process(_delta: float) -> void:
	
	if focus < max_focus and focus_regen_timer.is_stopped():
		focus_regen_timer.start(0.2)
		await focus_regen_timer.timeout
		focus += 1

func player_hit(damage : int ,_knockback_dir : Vector2 ,_knockback_force : float,_knockback_dur,received_index : int,hit_player_index) -> void:
	if received_index == player_index : return
	if hit_player_index == player_index:
		health -= damage

func player_blocked(blocked_damage, recieved_index) -> void:
	if recieved_index == player_index:
		print(blocked_damage)
		focus -= (blocked_damage/10) * 2

#Uses EventBus pattern to update UI in game
func update_health(new_health : int) -> void:
	EventHandler.player_health_changed.emit(new_health,player_index)

#Uses EventBus pattern to update UI in game
func update_focus(new_focus : int) -> void:
	EventHandler.player_focus_changed.emit(new_focus,player_index)
