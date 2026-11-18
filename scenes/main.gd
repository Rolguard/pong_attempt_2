extends Node

@export var ball_scene: PackedScene
@onready var ball: CharacterBody2D = $Ball
@onready var ball_start_marker: Marker2D = $BallStartPosition
@onready var score: Score = %Score

# The main world/level manager scene node should be responsible in my opinion for
# updating the score when the ball has passed the boundary.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ball.position = ball_start_marker.position

func respawn_ball(position: Vector2) -> void:
	var ball_instance: Ball = ball_scene.instantiate()
	ball_instance.global_position = position
	add_child(ball_instance)

	ball_instance.modulate = Color.TRANSPARENT
	var initial_velocity: Vector2 = ball_instance.velocity
	
	
	var fade_in_tween: Tween = create_tween()
	var fade_in_duration: float = 1.0
	fade_in_tween.tween_property(ball_instance, "modulate:a", 1, fade_in_duration)
	
	# Set velocity to 0 until the fade in tween animation completes, so the player can see the ball 
	# before it starts moving in a randomised direction
	ball_instance.velocity = Vector2(0, 0)
	await fade_in_tween.finished
	
	ball_instance.velocity = initial_velocity


func _on_ball_respawn_timer_timeout() -> void:
	print("Ball respawn timer has timed out, attempting to respawn ball...")
	respawn_ball(ball_start_marker.position)

func _on_player_1_score_area_body_exited(body: Node2D) -> void:
	if body is Ball:
		score.increment_player_1_score()


func _on_player_2_score_area_body_exited(body: Node2D) -> void:
	if body is Ball:
		score.increment_player_2_score()
