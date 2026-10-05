extends CharacterBody2D
class_name Ball


const SPEED: int = 50
var direction: Vector2 = Vector2(1, 0)
@export var initial_velocity: Vector2 = direction * SPEED

# _process - Idle processing, for running code that updates every frame, as soon as possible

# TODO: Look at bouncing bullet of walls example, should help me with pong ball bouncing on collision with paddle
# https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html

# Niceeeeee I got the bouncing working, although it kinda glitches out when you spam the direction key on the ball.
# - Need to make it work with colliding at an angle
# - Randomise the starting direction of the ball so it can come at many different angles, not just horizontal.
# - Test ball bouncing on wall
# - When the ball goes out of bounds, it should respawn after 5 seconds (later we add a point)

func _ready() -> void:
	velocity = initial_velocity

func _physics_process(delta: float) -> void:
	# Physics processing occurs at a fixed rate, 60 FPS by default.
	# Used for anything that involves the physics engine
	
	
	# Reminder: delta is the time elapsed in seconds since the last frame was displayed (last time _process was called)
	# We multiply position by delta to ensure players with different FPS get consistent movement
	# So movement is independent of the framerate. A player with a higher FPS will have a lower
	# delta because less time has elapsed since the last frame was rendered.
	# So since delta is smaller, when we multiply the position moved will be smaller.
	# Equivalent for the player with low FPS, delta will be higher since more time has passed
	# since we have rendered the last frame to the user. In this case, since delta is higher
	# the position moved will be greater.
	
	#  If you’ve got a force that’s applied proportionally over time, you want to scale by delta.
	# https://forum.godotengine.org/t/should-i-multiply-every-physics-calculation-by-delta-to-make-them-frame-rate-independent-is-it-even-necessary/105746
	
	#velocity = direction * SPEED
	var collision = move_and_collide(velocity * delta)
	if collision:
		print("I collided with ", collision.get_collider().name)
		print("Velocity before collision: {velocity}".format({"velocity": velocity}))
		velocity = velocity.bounce(collision.get_normal())
		print("Velocity after collision: {velocity}".format({"velocity": velocity}))
