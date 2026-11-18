extends CharacterBody2D
class_name Paddle

@export var movement_speed: int = 200
@export var controls: PlayerControls = null
@onready var screen_start_boundary: Vector2
@onready var screen_end_boundary: Vector2
@onready var paddle_size: Vector2 = $CollisionShape2D.shape.size

# We want to set movement_acceleration so the player paddle doesn't start moving at
# a constant max speed immediately, we want to ease into it.
# One reason for this is because I want the player to accelerate and if they hit max speed
# when they hit the ball it will travel faster than if they just lightly tap the arrow key
# and push the ball.
@export var movement_acceleration: float = 0.3

const MAX_SPEED: int = 300

# Have set motion_mode to floating to prevent paddle from sticking to ball as a moving platform.

func _ready() -> void:
	# We need to account for the size of the paddle when determining the clamping of the paddle position
	# This makes it so our sprite/collisionshape does not go out of bounds of the screen
	screen_start_boundary = Vector2.ZERO + paddle_size
	screen_end_boundary = get_viewport_rect().size - paddle_size
	
	# Set default starting position for each player's paddles based on the viewport size
	if controls.is_player_one():
		position.x = get_viewport_rect().size.x / 4 - paddle_size.x
	elif controls.is_player_two():
		position.x = (get_viewport_rect().size.x / 4) * 3 + paddle_size.x

func _physics_process(_delta: float) -> void:
	# Input.get_vector() already normalises length of vector to 1 to prevent faster diagonal movement
	# Other approaches e.g. 
	# var input_vector: Vector2 = Vector2.ZERO
	# input_vector = Input.get_action_strength("right") - Input.get_action_strength("left")
	# Require using .normalized() e.g. velocity = input_vector.normalized() * movement_speed
	var input_direction: Vector2 = Input.get_vector(controls.move_left, controls.move_right, 
											controls.move_up, controls.move_down)
	
	# We will set the paddle to a constant speed
	velocity = input_direction * movement_speed
	
	# EXPERIMENT: Accelerating paddle speed up to a maximum speed on user input
	# When no player input, Input.get_vector returns Vector2.ZERO, which evaluates to false.
	#if input_direction:
		#velocity += input_direction * movement_speed * movement_acceleration
		#velocity = velocity.limit_length(MAX_SPEED)
	#else:
		## Reset velocity back to 0, so we only move on user input
		## We could use velocity.move_towards(Vector2.ZERO. movement_speed * movement_acceleration)
		## But I don't want a slippery/snowy biome movement decceleration, it should be responsive and immediate stop
		#velocity = Vector2.ZERO
	
	move_and_slide()
	
	
	# I think I want move_and_collide instead of move_and_slide so the paddle doesn't slide around the ball?
	
	
	
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#print("I collided with ", collision.get_collider().name)
	
	# Detect if we have collided with the ball and if so, the ball should 
	# Receive an impulse/force, which we need to add programatically since we are using
	# Area2D for the ball. I used Area2D over a RigidBody2D which uses
	# Godot's built-in physics engine because I wanted better control over the movement
	# Of the ball, it was not getting the exact speed and angle I wanted.
	# You could use CharacterBody2D for the ball/projectile, but it seems to have performance
	# issues and is overkill according to: https://www.reddit.com/r/godot/comments/1tlo583/pros_and_cons_of_making_projectiles_area2d_or/
	
	# However, since we are using Area2D, the CharacterBody2D node for the paddle won't detect
	# the ball because Area2D nodes do not have a physical mass/blocking body.
	# Area2D nodes do not collide, but they can detect and influence (via signals).
	# Source: https://www.reddit.com/r/godot/comments/1lmk6x9/characterbody2d_cant_detect_when_colliding_with/
	
	position = position.clamp(screen_start_boundary, screen_end_boundary)
