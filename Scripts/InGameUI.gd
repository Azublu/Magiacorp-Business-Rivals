extends Control

@export_category("Player 1")
@export var player1_health : ProgressBar
@export var player1_damaged_health : ProgressBar
@export var player1_damaged_timer: Timer

@export var player1_focus1 : ProgressBar
@export var player1_focus2 : ProgressBar
@export var player1_focus3 : ProgressBar
@export var player1_focus4 : ProgressBar
@export var player1_focus5 : ProgressBar

@export_category("Player 2")
@export var player2_health : ProgressBar
@export var player2_damaged_health: ProgressBar
@export var player2_damaged_timer: Timer

@export var player2_focus1 : ProgressBar
@export var player2_focus2 : ProgressBar
@export var player2_focus3 : ProgressBar
@export var player2_focus4 : ProgressBar
@export var player2_focus5 : ProgressBar

var p1_current_health : float = 1000
var p1_current_focus : float = 100

var p2_current_health : float = 1000
var p2_current_focus : float  = 100

func _ready() -> void:
	EventHandler.player_health_changed.connect(update_health)
	EventHandler.player_focus_changed.connect(update_focus)
	player1_damaged_timer.timeout.connect(on_player1_damaged_timer_timeout)
	player2_damaged_timer.timeout.connect(on_player2_damaged_timer_timeout)

func update_health(health_value : int, player_index : int) -> void:
	match player_index:
		0:
			player1_health.value = health_value
			player1_damaged_timer.start(1)
		1:
			player2_health.value = health_value
			player2_damaged_timer.start(1)
		_: 
			print("Invalid Player Index")

#Handles updating the multiple blue bars under player health
func update_focus(focus_value : int, player_index : int) -> void:
	match player_index:
		1:
			p1_current_focus = lerp(p1_current_focus, focus_value,1)
			if focus_value < 80:
				pass
		2:
			pass
		_:
			print("Invalid Player Index")

func on_player1_damaged_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self, "player1_damaged_health:value", player1_health.value,0.15)

func on_player2_damaged_timer_timeout():
	var tween = create_tween()
	tween.tween_property(self, "player2_damaged_health:value", player2_health.value,0.15)
