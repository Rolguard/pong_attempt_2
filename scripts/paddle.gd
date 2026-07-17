extends CharacterBody2D
class_name Paddle

@export var movement_speed: int = 200
@export var controls: PlayerControls = null
@onready var screen_start_boundary: Vector2
@onready var screen_end_boundary: Vector2
@onready var paddle_size: Vector2 = $CollisionShape2D.shape.size

func _ready() -> void:
	# We need to account for the size of the paddle when determining the clamping of the paddle position
	# This makes it so our sprite/collisionshape does not go out of bounds of the screen
	screen_start_boundary = Vector2.ZERO + paddle_size
	screen_end_boundary = get_viewport_rect().size - paddle_size

func _physics_process(delta: float) -> void:
	# Input.get_vector() already normalises length of vector to 1 to prevent faster diagonal movement
	# Other approaches e.g. 
	# var input_vector: Vector2 = Vector2.ZERO
	# input_vector = Input.get_action_strength("right") - Input.get_action_strength("left")
	# Require using .normalized() e.g. velocity = input_vector.normalized() * movement_speed
	var input_direction: Vector2 = Input.get_vector(controls.move_left, controls.move_right, 
											controls.move_up, controls.move_down)
	velocity = input_direction * movement_speed
	
	move_and_slide()
	# Detect if we have collided with the ball and if so, the ball should 
	# Receive an impulse/force, which we need to add programatically since we are using
	# CharacterBody2D for the ball. I used CharacterBody2D over a RigidBody2D which uses
	# Godot's built-in physics engine because I wanted better control over the movement
	# Of the ball, it was not getting the exact speed and angle I wanted.
	for i: int  in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(i)
	
	
	position = position.clamp(screen_start_boundary, screen_end_boundary)
