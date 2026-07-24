extends CharacterBody2D
class_name Player


@export_category("Movement Settings")
@export var move_speed: float = 250.0

@export_category("Jump Settings")
@export var jump_height: float = 100.0
@export var jump_time_to_apex: float = 0.5
@export var jump_time_to_fall: float = 0.4
@export var terminal_velocity: float = 500.0
@export var jump_release_modifier: float = 0.6

var was_on_floor: bool

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += get_true_gravity() * delta
		velocity.y = minf(velocity.y, terminal_velocity)
	
	# Start the jump buffer timer if the jump key is pressed
	if jump_just_pressed():
		jump_buffer_timer.start()
	
	# Handle jumping and variable jump height
	if can_jump():
		velocity.y = get_jump_velocity()
		coyote_timer.stop()
		jump_buffer_timer.stop()
	elif is_moving_upwards() and jump_just_released():
		velocity.y *= jump_release_modifier
	
	# Set horizontal velocity
	var direction := get_direction()
	if direction:
		velocity.x = direction * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
	
	move_and_slide()
	
	# Handle coyote time
	if was_on_floor and was_on_floor != is_on_floor():
		if not is_moving_upwards():
			coyote_timer.start()
	
	# Update was_on_floor for the next frame
	was_on_floor = is_on_floor()


func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")


func jump_just_pressed() -> bool:
	return Input.is_action_just_pressed("jump")


func jump_just_released() -> bool:
	return Input.is_action_just_released("jump")


func is_moving_upwards() -> bool:
	return velocity.y < 0.0


func get_jump_velocity() -> float:
	return ((2.0 * jump_height) / \
	jump_time_to_apex) * -1.0


func get_jump_gravity() -> float:
	return ((-2.0 * jump_height) / \
	(jump_time_to_apex ** 2)) * -1.0


func get_fall_gravity() -> float:
	return ((-2.0 * jump_height) / \
	(jump_time_to_fall * jump_time_to_apex)) * -1.0

func get_true_gravity() -> float:
	var grav: float
	if is_moving_upwards():
		# Return jump gravity
		grav = get_jump_gravity()
	else:
		# Return fall gravity
		grav = get_fall_gravity()
	return grav

func can_jump() -> bool:
	return not jump_buffer_timer.is_stopped() and \
	(is_on_floor() or not coyote_timer.is_stopped())
