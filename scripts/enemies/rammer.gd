class_name Rammer
extends Enemy

@export var approach_speed := 80.0
@export var charge_speed := 460.0
@export var telegraph_duration := 0.7

var _state := 0
var _timer := 0.5
var _charge_direction := Vector2.DOWN

func _physics_process(delta: float) -> void:
	match _state:
		0:
			global_position.y += approach_speed * delta
			if global_position.y >= 190.0:
				_state = 1
				_timer = telegraph_duration
				modulate = Color(1.0, 0.72, 0.22)
		1:
			_timer -= delta
			if _timer <= 0.0:
				var player := get_tree().get_first_node_in_group("player") as Player
				_charge_direction = (player.global_position - global_position).normalized() if player != null else Vector2.DOWN
				_state = 2
				modulate = Color.WHITE
		2:
			global_position += _charge_direction * charge_speed * delta
	leave_arena_if_needed()
