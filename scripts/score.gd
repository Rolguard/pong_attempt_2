extends RichTextLabel
class_name Score

# Note: We need to set the CollisionShape2D to >1px, I believe because it inconsistently detects
# the ball passing it, maybe due to being too small to detect the ball at fast velocities
# then after 1 frame, the ball has already passed the 1px CollisionShape2D so no signal is emitted
# is my guess.
# Source: https://www.reddit.com/r/godot/comments/18090ec/player_area2d_only_rarely_detects_collision_with/

var player_1_score: int = 0
var player_2_score: int = 0

var text_effect: String = "wave"
var text_effect_2: String = "pulse"
@export var text_effect_reset_time: float = 3.0
#var default_text: String =  "{player_1_score} - {player_2_score}".format({"player_1_score": player_1_score, "player_2_score": player_2_score})

# NICE-TO-HAVE: Text popup effect when the score increments for a player
# We could like do a wavy all caps SCORE!! message, then a fade in animation for the actual score text to fade in

# The animation doesn't reset well, the wave should reset back to neutral rather than jump back to the default state
# Apparently the solution is either a tween or a custom rich text effect, but I don't want to mess to long with those, focus on other features

func reset_to_default_text(player_1_score: int, player_2_score: int) -> void:
	text = "{player_1_score} - {player_2_score}".format({"player_1_score": player_1_score, "player_2_score": player_2_score})

func increment_player_1_score() -> void:
	player_1_score += 1
	text = "[{t2}][{t}]{p1} - {p2}[/{t}][/{t2}]".format({"p1": player_1_score, "p2": player_2_score, "t": text_effect, "t2": text_effect_2})
	await get_tree().create_timer(text_effect_reset_time).timeout
	
	reset_to_default_text(player_1_score, player_2_score)

func increment_player_2_score() -> void:
	player_2_score += 1
	text = "[{t2}][{t}]{p1} - {p2}[/{t}][/{t2}]".format({"p1": player_1_score, "p2": player_2_score, "t": text_effect, "t2": text_effect_2})
	await get_tree().create_timer(text_effect_reset_time).timeout
	
	reset_to_default_text(player_1_score, player_2_score)
