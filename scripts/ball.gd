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
		
		
		# I was running into a bug where when the player paddle was travelling opposite direction to the ball
		# and the ball was higher velocity, sometimes for a few seconds, the ball would like jitter/stutter/glitch out
		# on the contact point of the ball and the paddle.
		# If I had to guess, it's something to do with the physics where the ball detects collision
		# with the paddle, it bounces and flips the direction velocity. But then the paddle velocity gets
		# registered in the physics engine and it now overlaps the bounced ball, so the ball bounces again.
		# This causes the jitter effect where the ball and paddle keep colliding.
		# I'm guessing we break out of this as the ball accelerates per bounce or the player paddle stops inputting the directional key.
		
		# The code below seems to fix the problem
		# TODO: Investigate cause of the issue and why the code below probably addresses the issue, not sure though
		# Source: https://forum.godotengine.org/t/ball-gets-stuck-instead-of-bouncing-using-bounce-and-move-and-collide/88102
		# https://forum.godotengine.org/t/a-physics-body-freezes-when-moved-by-another-one/133729
		
		#var normal: Vector2 = collision.get_normal()
		#if normal.dot(velocity.normalized()) <= 0.0:
			#velocity = velocity.bounce(normal)
		#velocity = velocity.bounce(collision.get_normal())
		
		
		# EXPERIMENT:
		# We know we increase the velocity by multiplying it by a positive number > 1.
		# So perhaps what we want to do is get the magnitude of the paddle's velocity.
		# Then we multiply that magnitude in combination with a reduction multiplier to ensure
		# it doesn't increase the speed too much but it should 
		
		# My plan is to add movement_acceleration to paddle so that its not a constant +1, -1 * movement speed
		# Now if we accelerate, then at max acceleration, the ball will bounce more, then if it was the initial part
		# of the movement
		# Source: https://forum.godotengine.org/t/how-to-make-speed-increase-with-movement-acceleration/99103/3
		# https://www.google.com/search?q=can+input+player+movement+accelerate+to+a+max+speed+godot&sca_esv=40ca210b90be4ad9&rlz=1C1FHFK_en-GBAU933AU933&sxsrf=AKL5yDgrMj9J2zZnGY07wDXEjf3IbucB7A%3A1794395603717&ei=0030aoqiK-O32roP6vz0mAs&biw=2560&bih=1279&uact=5&oq=can+input+player+movement+accelerate+to+a+max+speed+godot&gs_lp=Egxnd3Mtd2l6LXNlcnAiOWNhbiBpbnB1dCBwbGF5ZXIgbW92ZW1lbnQgYWNjZWxlcmF0ZSB0byBhIG1heCBzcGVlZCBnb2RvdDIFECEYoAEyBRAhGKABMgUQIRigATIFECEYoAEyBRAhGKABSPUGUIMDWKIGcAF4AJABAJgBkwKgAdoFqgEDMi0zuAEDyAEA-AEBmAIEoALpBcICCBAAGO8FGLADwgIFEAAY7wWYAwCIBgGQBgWSBwUxLjAuM6AH7Q-yBwMyLTO4B-UFwgcDMC40yAcIgAgB&sclient=gws-wiz-serp
		
		# If I can't make it work as I think in my head, this is actually a decent compromise
		#if velocity.length() < MAXIMUM_MAGNITUDE:
			#velocity *= bounce_speed_multiplier
		#velocity = velocity.limit_length(MAXIMUM_MAGNITUDE)
		
		
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
	
