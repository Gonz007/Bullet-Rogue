class_name PredictiveChaser
extends Chaser

@export var prediction_time := 0.42

func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		var predicted_x := player.global_position.x + player.velocity.x * prediction_time
		global_position.x = move_toward(global_position.x, clampf(predicted_x, 24.0, 456.0), horizontal_speed * delta)
	global_position.y += descent_speed * delta
	leave_arena_if_needed()
