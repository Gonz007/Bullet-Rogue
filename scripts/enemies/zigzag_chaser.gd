class_name ZigzagChaser
extends Chaser

@export var zigzag_width := 80.0
@export var zigzag_frequency := 2.5
var _time := 0.0

func _physics_process(delta: float) -> void:
	_time += delta
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		var target_x := player.global_position.x + sin(_time * zigzag_frequency) * zigzag_width
		global_position.x = move_toward(global_position.x, target_x, horizontal_speed * delta)
	global_position.y += descent_speed * delta
	leave_arena_if_needed()
