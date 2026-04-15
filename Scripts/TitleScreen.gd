extends Control

@onready var camera_2d: Camera2D = $Camera2D
@onready var back: Button = %Back
@onready var versus: Button = $VBoxContainer/Versus

func _ready() -> void:
	versus.grab_focus()


func _on_credits_pressed() -> void:
	back.grab_focus()
	var tween = create_tween()
	tween.tween_property(camera_2d, "position", Vector2(-777,540),0.15)


func _on_back_pressed() -> void:
	versus.grab_focus()
	var tween = create_tween()
	tween.tween_property(camera_2d, "position", Vector2(960,540),0.15)
