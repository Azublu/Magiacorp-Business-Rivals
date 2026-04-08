extends CharacterBody2D

const DASH_PARTICLES = preload("uid://vhwsu32nmgvh")

const ACCELERATION = 7000.0
const FRICTION = 7000.0

const GRAVITY := 2000.0
const FALL_GRAVITY := 3000.0
const FAST_FALL_GRAVITY := 5000.0
const SLOW_FALL_GRAVITY := 1800.0

@export_category("Components")
@export var player_index = 0
@export var sprite : Sprite2D
@export var animation_tree : AnimationTree
@export var dash_timer : Timer
@export var focus_regen_timer: Timer

@export_category("Character Stats")
@export var default_speed : float = 400
@export var dash_speed : float = 1000
@export var jump_velocity : float = -1000
@export var max_jumps : int = 2
@export var dash_cooldown : float = 0.25
@export var dash_duration : float = 0.25
@export var max_health : int = 1000
@export var max_focus : int = 100

var health : int = 1000:
	set(value):
		health = value
		if health <= 0:
			pass
var focus : int = 100:
	set(value):
		focus = value
		update_focus(focus)

var input_velocity : Vector2 = Vector2.ZERO
var speed : float

var facing_left : bool = true
var can_move : bool = true
var dashing : bool = false

var jump_input : bool
var jump_pressed : bool
var jump_attempted : bool
var jump_buffer_time : float = 0.1
var jump_buffer_counter : float = 0.0
var available_jumps : int

enum States {GROUNDED,AIRBORNE,DASHING}
var state : States = States.GROUNDED : set = set_state

func _ready() -> void:
	available_jumps = max_jumps

func _process(_delta: float) -> void:
	if velocity.x > 5 and facing_left:

		sprite.scale.x = -1.0
		facing_left = false
	elif velocity.x < -5 and not facing_left:

		sprite.scale.x = 1.0
		facing_left = true

	if focus < max_focus and focus_regen_timer.is_stopped():
		focus_regen_timer.start(0.2)
		await focus_regen_timer.timeout
		focus += 1

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		focus -= 10
	var floor_damping : float = 1.0 if is_on_floor() else 0.2
	var horizontal_input := InputHandler.get_horizontal_input(player_index)
	var dash_input := InputHandler.get_dash_input(player_index)
	input_velocity = Vector2.ZERO
	
	if not is_on_floor():
		velocity.y += _get_gravity() * delta
	else:
		available_jumps = max_jumps

	dash(dash_input)
	jump()
	if horizontal_input and not dashing:
		velocity.x = move_toward(velocity.x, horizontal_input * speed, ACCELERATION * delta)
	elif dashing:
		if horizontal_input > 0.1:
			velocity.x = 1 * dash_speed
		elif horizontal_input < -0.1:
			velocity.x = -1 * dash_speed
		else:
			if facing_left:
				velocity.x = -1 * dash_speed
			else:
				velocity.x = 1 * dash_speed
	else:
		velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)
	
	##NOTE: State Machine
	match state:
		States.GROUNDED:
			speed = default_speed
			if dashing:
				state = States.DASHING
			if not is_on_floor():
				state = States.AIRBORNE
		States.AIRBORNE:
			if is_on_floor():
				state = States.GROUNDED
		States.DASHING:
			if not dashing:
				if is_on_floor():
					state = States.GROUNDED 
				else:
					state = States.AIRBORNE

	move_and_slide()

func set_state(new_state: States) -> void:
	var previous_state := state
	state = new_state
	
	print("STATE CHANGED: " + str(state))
	
	match state:
		States.GROUNDED:
			pass
		States.AIRBORNE:
			pass
		States.DASHING:
			
			can_move = false

	match previous_state:
		States.GROUNDED:
			pass
		States.AIRBORNE:
			pass
		States.DASHING:
			can_move = true

func jump() -> void:
	##NOTE: Attempt to handle buffering jump inputs
	jump_input = InputHandler.get_jump_input(player_index)
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

func dash(dash_input) -> void:
	if dash_input and dash_timer.is_stopped():
		
		var new_dash_particle = DASH_PARTICLES.instantiate()
		if facing_left:
			new_dash_particle.scale.x = -1.0
		add_child(new_dash_particle)
		dashing = true
		dash_timer.start(dash_duration)
		await dash_timer.timeout
		dashing = false
		dash_timer.start(dash_cooldown)

func update_focus(new_focus : int):
	EventHandler.player_health_changed.emit(new_focus,player_index)

func _get_gravity() -> float:
	var vertical_input = InputHandler.get_vertical_input(player_index)
	if vertical_input > 0.5:
		return FAST_FALL_GRAVITY
	return GRAVITY if velocity.y < 0 else FALL_GRAVITY
