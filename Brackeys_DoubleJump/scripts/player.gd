extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# ADDITION START: double-jump state and feedback.
signal jumps_changed(remaining: int)
const MAX_JUMPS = 2
const AIR_JUMP_VELOCITY = -270.0
var jumps_remaining: int = MAX_JUMPS
var was_grounded: bool = false
var air_jump_flash: float = 0.0

func refill_jumps():
	jumps_remaining = MAX_JUMPS
	jumps_changed.emit(jumps_remaining)

func try_jump() -> bool:
	if jumps_remaining <= 0:
		return false
	var is_air_jump: bool = not is_on_floor()
	velocity.y = AIR_JUMP_VELOCITY if is_air_jump else JUMP_VELOCITY
	jumps_remaining -= 1
	jumps_changed.emit(jumps_remaining)
	if is_air_jump:
		air_jump_flash = 0.18
	return true
# ADDITION END

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# ADDITION START: refill on landing and consume jumps on each press.
	var grounded: bool = is_on_floor()
	if grounded and not was_grounded:
		refill_jumps()
	# Walking off an edge leaves one air jump, not two.
	if not grounded and was_grounded and jumps_remaining == MAX_JUMPS:
		jumps_remaining = 1
		jumps_changed.emit(jumps_remaining)
	if Input.is_action_just_pressed("jump"):
		try_jump()
	was_grounded = grounded
	air_jump_flash = maxf(0.0, air_jump_flash - delta)
	animated_sprite.modulate = Color(0.5, 1.0, 1.0) if air_jump_flash > 0.0 else Color.WHITE
	# ADDITION END

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip the Sprite
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Play animations
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")
	
	# Apply movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
