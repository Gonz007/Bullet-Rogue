class_name Chaser
extends Enemy

@export var descent_speed := 62.0
@export var horizontal_speed := 145.0


func _physics_process(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		global_position.x = move_toward(global_position.x, player.global_position.x, horizontal_speed * delta)
	global_position.y += descent_speed * delta
	leave_arena_if_needed()
