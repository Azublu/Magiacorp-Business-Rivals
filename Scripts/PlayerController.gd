extends CharacterBody2D

const ACCELERATION = 7000.0
const FRICTION = 7000.0

const GRAVITY := 2000.0
const FALL_GRAVITY := 3000.0
const FAST_FALL_GRAVITY := 5000.0
const SLOW_FALL_GRAVITY := 1800.0

@export var player_index = 0
@export var speed : float = 400
@export var jump_velocity : float = -1000
#@export var aim_pivot : Marker2D
@export var sprite : Sprite2D
@export var animation_tree : AnimationTree

@export var maxJumps : int = 2

var input_velocity : Vector2 = Vector2.ZERO
var horizontal_input : float
var vertical_input : float
var facing_left : bool = true
#var aim_vertical : float
#var aim_horizontal : float
#var aim_direction : Vector2

var jump_input : bool
var jump_pressed : bool
var jump_attempted : bool
var jump_buffer_time : float = 0.1
var jump_buffer_counter : float = 0.0
var available_jumps : int

func _ready() -> void:
	available_jumps = maxJumps

func _process(_delta: float) -> void:
	get_player_input()
	#if aim_direction.length() > 0.7:
		#aim_pivot.rotation = aim_direction.angle()
	if velocity.x > 5 and facing_left:

		sprite.scale.x = -1.0
		facing_left = false
	elif velocity.x < -5 and not facing_left:

		sprite.scale.x = 1.0
		facing_left = true


func _physics_process(delta: float) -> void:
	input_velocity = Vector2.ZERO
	
	if not is_on_floor():
		velocity.y += _get_gravity() * delta
	else:
		available_jumps = maxJumps
	
	jump()
	
	var floor_damping : float = 1.0 if is_on_floor() else 0.2
	
	if horizontal_input:
		velocity.x = move_toward(velocity.x, horizontal_input * speed, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)
		
	

	move_and_slide()

func get_player_input() -> void:
	horizontal_input = Input.get_joy_axis(player_index,JOY_AXIS_LEFT_X)
	vertical_input = Input.get_joy_axis(player_index,JOY_AXIS_LEFT_Y)
	
	#aim_horizontal = Input.get_joy_axis(player_index,JOY_AXIS_RIGHT_X)
	#aim_vertical = Input.get_joy_axis(player_index,JOY_AXIS_RIGHT_Y)
	#aim_direction = Vector2(aim_horizontal,aim_vertical).normalized()


func jump() -> void:
	#if is_on_floor() and jump_pressed:
		#velocity.y = jump_velocity
	jump_input = Input.is_joy_button_pressed(player_index,JOY_BUTTON_A)
	if jump_input and not jump_pressed:
		
		if not is_on_floor() and available_jumps > 0:
			available_jumps -= 1
			velocity.y = jump_velocity
		
		if jump_buffer_counter > 0:
			jump_buffer_counter -= get_physics_process_delta_time()
		
		if jump_pressed:
			jump_buffer_counter = jump_buffer_time

		if is_on_floor() and jump_buffer_counter > 0:
			available_jumps -= 1
			velocity.y = jump_velocity
			jump_buffer_counter = 0
		elif is_on_floor():
			available_jumps -= 1
			velocity.y = jump_velocity
	jump_pressed = jump_input
	
	if !jump_pressed:
		if velocity.y < -100:
			velocity.y = -100
	
func _get_gravity() -> float:
	
	
	if vertical_input > 0.5:
		return FAST_FALL_GRAVITY
	return GRAVITY if velocity.y < 0 else FALL_GRAVITY
