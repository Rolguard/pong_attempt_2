extends CharacterBody2D
class_name Ball

@onready var ball_respawn_timer: Timer = $"../BallRespawnTimer"
@export var speed: int = 100
@export var bounce_speed_multiplier: float = 1.1
@export var maximum_magnitude: float = 180
#@export var start_position: Vector2 = $StartPosition.position

# _process - Idle processing, for running code that updates every frame, as soon as possible

# Have set motion_mode to floating to prevent paddle from sticking to ball as a moving platform.


func _ready() -> void:
	# Randomise the intial velocity starting direction, using our custom random_float function
	# to ensure we don't get any vector directions near 0, which causes the ball to not move towards any player
	# instead staying close to the middle.
	#print("Start Position: {start_position}").format({start_position: })
	
	var minimum_direction: float = 0.3
	var maximum_direction: float = 1

	var direction: Vector2 = Vector2(Utilities.random_float(minimum_direction, maximum_direction), Utilities.random_float(minimum_direction, maximum_direction))
	
	# We want to normalise the randomised direction vector into a unit vector so it simply represents
	# direction without adding magnitude.
	# The past problem I had before was the ball would be travelling at different speeds,
	# depending on the values in the direction vector, which influenced magnitude.
	direction = direction.normalized()
	var initial_velocity: Vector2 = direction * speed

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
		print("The ball has collided with ", collision.get_collider().name)
		print("Velocity before collision: {velocity}".format({"velocity": velocity}))
		
		
		# We check the dot product of the normal vector for the collision (the direction vector the collision surface is facing)
		# The dot product of two vectors is a math operation that takes two vectors,
		# multiplies their components and adds up their results.
		# The algebraic formula is like: a . b = (a1 * b1) + (a2 * b2) 
		
		# The reason we normalize the vectors is due to this 2nd geometric formula:
		# Dot product of two vectors (a . b) = |a| * |b| * cos(theta)
		
		# If |a| and |b| are both = 1, which happens when we normalize vectors, then
		# the dot product gives us cos(theta).
		# We can imagine a ball travelling right with a right side paddle facing left. 
		# The normal of the collision is the direction the right side paddle is facing, which is left.
		# If the ball's direction vector also faces the same direction (left), then the degrees between the vectors is 0°.
		# Cos(0) = 1.
		# If the ball's direction vector is perpendicular to the normal of the collision, then
		# the degrees between vectors is 90 degrees. Cos(90) = 0.
		# If the ball's direction vector faces the opposite direction (right), then 
		# the degrees between the vectors is 180 degrees. Cos(180) = -1
		# The cosine is positive from 0° to 90°, zero at exactly 90°, and negative from 90° to 180°
		
		# So we can use the dot product to determine how much two vectors point in the same direction or align.
		# If the normal vector of the collision and the ball velocity's dot product is <= 0, 
		# then the ball is travelling opposite to the collision normal (where the paddle is facing).
		# So that means, the ball is travelling into the paddle, and so we want to bounce.
		# Now if there is another collision check but a bounce has already occurred,
		# the ball is now travelling aligned with the previous collision normal, 
		# which means the dot product will be positive and another bounce will not occur, thus preventing the bug.
		

		
		# According to Godot documentation: 
		# When using unit (normalized) vectors, the result will always be between -1.0 (180 degree angle) 
		# when the vectors are facing opposite directions, and 1.0 (0 degree angle) when the vectors are aligned.
		# Source: https://docs.godotengine.org/en/stable/classes/class_vector2.html#class-vector2-method-dot
		
		# This helps prevent a bug where often when the ball is at high velocities and travels to the paddle
		# and the player spams the directional key towards the ball, it would bounce back and forth quickly
		# on the collision point, jittering. I think this is because after the paddle moves into the ball's path
		# we calculate the bounce but in the next physics frame, the paddle is still contacting/touching
		# the ball, so it causes the ball to bounce again. We get out of this cycle because we increase
		# the velocity of the ball upon every collision so eventually, the ball escapes the player's
		# paddle collision area so we don't get continous bouncing.
		
		# Inspiration source code for similar problem:
		# https://forum.godotengine.org/t/ball-gets-stuck-instead-of-bouncing-using-bounce-and-move-and-collide/88102
		# https://forum.godotengine.org/t/a-physics-body-freezes-when-moved-by-another-one/133729

		
		var normal: Vector2 = collision.get_normal()
		if normal.dot(velocity.normalized()) <= 0.0:
			velocity = velocity.bounce(normal)
			
		# Using above, instead of just bouncing
		#velocity = velocity.bounce(collision.get_normal())
		
		# TODO: Could be useful code for acceleration. But I'll experiment and research it later in the backlog
		#var collider := collision.get_collider()
		#if collider is Paddle:
			#var push: float = collider.velocity.dot(normal)  # >0 means paddle moving toward the ball
			#if push > 0.0:
				#velocity += normal * push * 0.5
		
		
		# TODO: Multiplty the velocity of the ball based on the magnitude
		# Then apply a dampening effect on the magnitude so it doesn't increase the velocity by a crazy amount
		# By multiplying by the magnitude of the paddle, we apply a velocity relationship between the ball and the paddle
		# based on the movement speed of the paddle.
		
		if velocity.length() < maximum_magnitude:
			velocity *= bounce_speed_multiplier
			
		velocity = velocity.limit_length(maximum_magnitude)
		print("Velocity after collision: {velocity}".format({"velocity": velocity}))
		print("Velocity magnitude after collision: {magnitude}".format({"magnitude": velocity.length()}))

# Credit for detecting when node exits screen/viewport https://github.com/kidscancode/godot_recipes/blob/master/src-3/content/2D/enter_exit_screen.md
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Note: Because we call queue_free() when the ball exits the screen, that causes the
	# ScoreArea to emit the signal that the ball has exited its area and updates the score.
	# I want to wait a small delay, so the player can register that the ball went past their boundary, before the ball would be half way across
	# passing not fully and the score would update
	
	# TODO: Could put sound effect of player scoring around here
	await get_tree().create_timer(0.4).timeout
	queue_free()
	print("Ball has been queued freed")
	ball_respawn_timer.start()
	print("Ball respawn timer has started")
	# Then after 3 seconds we want to spawn another ball
	
