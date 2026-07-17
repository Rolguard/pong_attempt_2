extends Area2D
class_name Ball

func _physics_process(delta: float) -> void:
	pass

# So I can get the body that entered through the body variable
# But can I get the velocity of the body so that I can do the normal to that or something
# And make the ball go the appropriate direction?
# Useful links for next time:
# https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html#detecting-collisions
# https://www.youtube.com/watch?v=z9d8BU1o3Zw
# https://docs.godotengine.org/en/stable/getting_started/first_2d_game/03.coding_the_player.html#preparing-for-collisions
func _on_body_entered(body: Node2D) -> void:
	if body is Paddle:
		
		print("Ball is detecting Paddle body entering its area.")
