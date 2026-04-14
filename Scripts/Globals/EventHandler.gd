extends Node

##NOTE: Singleton pattern designated through engine in
##Project > Project Settings > Globals

##NOTE: Adjusted signal script based on information gathered from:
##https://gdscript.com/solutions/signals-godot/

#TODO: Setup signals that other scripts connect to
signal player_health_changed(current_health,player_index)
signal player_focus_changed(current_focus, player_index)
signal player_hit(damage,knockback_dir,knockback_force,knockback_dur,player_index)

##NOTE: Attempt to translate Unity EventHandler into Godot
#static var event_dictionary : Dictionary[String,Array]
#
#func _init() -> void:
	#if event_dictionary == null:
		#event_dictionary = {}

#static func start_listening(event_name : String, event_signal : Signal) -> void:
	#if event_dictionary.has(event_name):
		#event_dictionary[event_name].append(event_signal)
	#else:
		#event_dictionary[event_name] = []
		#event_dictionary[event_name].append(event_signal)
#
#static func stop_listening(event_name : String, event_signal : Signal) -> void:
	#if event_dictionary.has(event_name):
		#event_dictionary[event_name].erase(event_signal)
#
#static func trigger_event(event_name : String, arg = null) -> void:
	#if event_dictionary.has(event_name):
		#for signals in event_dictionary[event_name]:
			#if arg != null:
				#signals.emit()
			#else:
				#signals.emit(arg)
