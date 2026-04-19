extends CharacterBody2D

const SPEED = 2000.0

@onready var left_warning: Label = %LeftWarning
@onready var right_warning: Label = %RightWarning

@onready var train_spawner_timer: Timer = $TrainSpawner

@export var left_spawn_marker : Marker2D
@export var right_spawn_marker : Marker2D
@export var up_spawn_marker : Marker2D

enum SpawnLocations {LEFT,RIGHT, UP}

var train_spawn : SpawnLocations

func _ready() -> void:
	left_warning.hide()
	right_warning.hide()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	match train_spawn:
		SpawnLocations.LEFT:
			velocity.x = -SPEED
		SpawnLocations.RIGHT:
			velocity.x = SPEED
		SpawnLocations.UP:
			velocity.x = 0

	move_and_slide()

func randomize_spawn() -> void:
	
	if GameManager.player1.dead or GameManager.player2.dead: return
	
	var random_spawn = randi_range(1,2)
	
	match random_spawn:
		1:
			train_spawn = SpawnLocations.LEFT
			global_position = left_spawn_marker.global_position
			for i in 3:
				right_warning.show()
				await get_tree().create_timer(0.2).timeout
				right_warning.hide()
				await get_tree().create_timer(0.2).timeout

		2:
			train_spawn = SpawnLocations.RIGHT
			global_position = right_spawn_marker.global_position
			for i in 3:
				left_warning.show()
				await get_tree().create_timer(0.2).timeout
				left_warning.hide()
				await get_tree().create_timer(0.2).timeout

		3:
			train_spawn = SpawnLocations.UP
			global_position = up_spawn_marker.global_position
		_:
			print("Invalid random spawn, somehow???")

func _on_train_spawner_timeout() -> void:
	randomize_spawn()
	train_spawner_timer.start(randf_range(5,7))
