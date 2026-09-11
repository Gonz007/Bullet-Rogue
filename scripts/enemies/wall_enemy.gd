class_name WallEnemy
extends Enemy

@export var descent_speed := 78.0


func _physics_process(delta: float) -> void:
	global_position.y += descent_speed * delta
	leave_arena_if_needed()
