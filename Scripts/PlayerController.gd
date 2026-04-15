extends CharacterBody2D
class_name Player

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
@export var hurtbox : Hurtbox
@export var hitbox : Hitbox
@export var health_component : HealthComponent
@export var shield : Sprite2D

@export_category("Character Stats")
@export var default_speed : float = 400
@export var dash_speed : float = 1000
@export var attack_speed : float = 200
@export var block_speed : float = 100
@export var jump_velocity : float = -1000
@export var max_jumps : int = 2
@export var dash_cooldown : float = 0.25
@export var dash_duration : float = 0.25

@export_category("InGame Variables")
@export var attacking : bool = false
@export var blocking : bool = false
@export var dead : bool = false

var input_velocity : Vector2 = Vector2.ZERO

var facing_left : bool = true
var can_move : bool = true
var dashing : bool = false
var on_hit : bool = false
var on_block : bool = false

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

var jump_input : bool
var jump_pressed : bool
var jump_attempted : bool
var jump_buffer_time : float = 0.1
var jump_buffer_counter : float = 0.0
var available_jumps : int

enum States {GROUNDED,AIRBORNE,DASHING,ATTACKING,BLOCKING}
var state : States = States.GROUNDED : set = set_state

##NOTE: Awake equivalent
func _init() -> void:
	EventHandler.player_hit.connect(player_hit)

##NOTE: Start equivalent
func _ready() -> void:
	match player_index:
		0:
			GameManager.player1 = self
		1:
			GameManager.player2 = self
	available_jumps = max_jumps
	if hurtbox:
		hurtbox.player_index = player_index
	if hitbox:
		hitbox.player_index = player_index
	if health_component:
		health_component.player_index = player_index
	else:
		print("Missing health component")

##NOTE: Update equivalent
func _process(_delta: float) -> void:
	if velocity.x > 5 and facing_left:
		if on_hit: return
		if on_block: return
		sprite.scale.x = -1.0
		facing_left = false
	elif velocity.x < -5 and not facing_left:
		if on_hit: return
		if on_block: return
		sprite.scale.x = 1.0
		facing_left = true

##NOTE: FixedUpdate equivalent
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += _get_gravity() * delta
	else:
		available_jumps = max_jumps
	
	##NOTE move this in the future when refining the player defeated state
	if dead: return ##TODO: Add dead animation

	var floor_damping : float = 1.0 if is_on_floor() else 0.2
	var horizontal_input := InputHandler.get_horizontal_input(player_index)
	var dash_input := InputHandler.get_dash_input(player_index)
	var attack_input := InputHandler.get_attack_input(player_index)
	var block_input := InputHandler.get_block_input(player_index)
	
	input_velocity = Vector2.ZERO
	
	dash(dash_input)
	jump()
	
	if knockback_timer > 0.0:
		if not on_block: on_hit = true 
		##NOTE: Can increase this for stronger vertical launch on knockback
		velocity.y = -100
		if knockback != Vector2.ZERO:
			velocity.x = knockback.x
			#velocity.y = -(abs(knockback.y) * 100)
			knockback_timer -= delta
		else:
			knockback_timer = 0.0
		if knockback_timer <= 0.0:
			knockback = Vector2.ZERO
			await get_tree().create_timer(0.25).timeout
			on_hit = false
			on_block = false
	else:

		##NOTE: Prevent blocking under 0 focus
		if health_component.focus <= 0 : 
			block_input = false
			hurtbox.shielding = false
	##NOTE: State Machine
		match state:
			States.GROUNDED:
				velocity.x = movement(horizontal_input,default_speed,floor_damping,delta)
				if dashing:
					state = States.DASHING
				if not is_on_floor():
					state = States.AIRBORNE
				if attack_input: 
					state = States.ATTACKING
				elif block_input:
					state = States.BLOCKING
			States.AIRBORNE:
				velocity.x = movement(horizontal_input,default_speed,floor_damping,delta)
				if dashing:
					state = States.DASHING
				if is_on_floor():
					state = States.GROUNDED
				if attack_input: 
					state = States.ATTACKING
				elif block_input:
					state = States.BLOCKING
			States.DASHING:
				if dashing:
					if horizontal_input > 0.1:
						velocity.x = 1 * dash_speed
					elif horizontal_input < -0.1:
						velocity.x = -1 * dash_speed
					else:
						if facing_left:
							velocity.x = -1 * dash_speed
						else:
							velocity.x = 1 * dash_speed
				elif not dashing:
					if is_on_floor():
						state = States.GROUNDED 
					else:
						state = States.AIRBORNE
			States.ATTACKING:
				velocity.x = movement(horizontal_input,attack_speed,floor_damping,delta)
				if not attacking and is_on_floor():
					state = States.GROUNDED
				elif not attacking:
					state = States.AIRBORNE
			States.BLOCKING:
				if is_on_floor():
					velocity.x = movement(horizontal_input,0,floor_damping,delta)
				else:
					velocity.x = movement(horizontal_input,default_speed,floor_damping,delta)
				if dashing:
					state = States.DASHING
				if not block_input and is_on_floor():
					state = States.GROUNDED
				elif not block_input:
					state = States.AIRBORNE
	move_and_slide()

##NOTE: Effectively an extended set function, triggers once when state is changed 
func set_state(new_state: States) -> void:
	var previous_state := state
	state = new_state

	match state:
		States.DASHING:
			attacking = false
			can_move = false
		States.ATTACKING:
			attacking = true
		States.BLOCKING:
			blocking = true
			shield.visible = true
			hurtbox.shielding = true

	match previous_state:
		States.DASHING:
			can_move = true
		States.BLOCKING:
			blocking = false
			shield.visible = false
			hurtbox.shielding = false

##NOTE: Handles movement logic
func movement(horizontal_input, speed : float, floor_damping :float,delta : float) -> float:
	if horizontal_input:
		return move_toward(velocity.x, horizontal_input * speed, ACCELERATION * delta)
	else:
		return move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)

##NOTE: Recieve player damage info from EventBus
func player_hit(damage : int ,knockback_dir : Vector2 ,knockback_force : float,knockback_dur,received_index : int) -> void:
	if received_index == player_index : return
	if damage == 0 : on_block = true
	apply_knockback(knockback_dir,knockback_force,knockback_dur)

##NOTE: Attempt to handle buffering jump inputs
func jump() -> void:
	jump_input = InputHandler.get_jump_input(player_index)
	if jump_input and not jump_pressed:
		
		#Allow for multiple jumps midair
		if not is_on_floor() and available_jumps > 0:
			available_jumps -= 1
			velocity.y = jump_velocity
		
		#Coyote timer 
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

##NOTE: Handles dash input and spawning dash particles
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

##NOTE: Handles gravity to allow for player to fast fall
func _get_gravity() -> float:
	var vertical_input = InputHandler.get_vertical_input(player_index)
	if vertical_input > 0.5:
		return FAST_FALL_GRAVITY
	if blocking:
		return FAST_FALL_GRAVITY
	return GRAVITY if velocity.y < 0 else FALL_GRAVITY

##NOTE: Applies a set amount of knockback that is controlled within Physics Process
func apply_knockback(direction: Vector2, force: float, knockback_dur: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_dur
