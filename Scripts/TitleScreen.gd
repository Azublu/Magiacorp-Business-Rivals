extends Control

@onready var camera_2d: Camera2D = $Camera2D
@onready var back: Button = %Back
@onready var versus: Button = $VBoxContainer/Versus

func _ready() -> void:
	versus.grab_focus()
	camera_2d.position = Vector2(960,540)

func _on_versus_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(camera_2d, "position", Vector2(960,-540),0.15)
	tween.tween_callback(change_scene).set_delay(0.2)

func _on_credits_pressed() -> void:
	back.grab_focus()
	var tween = create_tween()
	tween.tween_property(camera_2d, "position", Vector2(-777,540),0.15)

func _on_back_pressed() -> void:
	versus.grab_focus()
	var tween = create_tween()
	tween.tween_property(camera_2d, "position", Vector2(960,540),0.15)

func change_scene() -> void:
	GameManager.change_scene("CHAR_SELECT")
