extends CharacterBody2D
class_name Ball


@export var speed: int = 100

# _process - Idle processing, for running code that updates every frame, as soon as possible


# TODO:
# From this source: https://www.youtube.com/watch?v=MNGWbVNSKmo
# I think what we can do is when the ball goes off the screen, we call ball.queue_free()
# Then after 3 seconds, we respawn the ball in the centre with that random starting velocity
# But we fade it in using a tween, instead of appearing jarringly... hmmm

func _ready() -> void:
	# Randomise the intial velocity starting direction, using our custom random_float function
	# to ensure we don't get any vector directions near 0, which causes the ball to not move towards any player
	# instead staying close to the middle.
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
		print("I collided with ", collision.get_collider().name)
		print("Velocity before collision: {velocity}".format({"velocity": velocity}))
		velocity = velocity.bounce(collision.get_normal())
		print("Velocity after collision: {velocity}".format({"velocity": velocity}))

# Credit for detecting when node exits screen/viewport https://github.com/kidscancode/godot_recipes/blob/master/src-3/content/2D/enter_exit_screen.md
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	# TODO: Then after 3 seconds we want to spawn another ball
