class_name MovingShooter
extends Shooter

@export var oscillation_width := 125.0
@export var oscillation_speed := 1.6
var _center_x := 240.0
var _time := 0.0

func _ready() -> void:
	_center_x = global_position.x
	super()

func _physics_process(delta: float) -> void:
	_time += delta
	if global_position.y < hold_y:
		global_position.y += descent_speed * delta
	else:
		global_position.x = clampf(_center_x + sin(_time * oscillation_speed) * oscillation_width, 40.0, 440.0)
	_fire_time -= delta
	if _fire_time <= 0.0:
		_fire_time = fire_interval
		_fire_at_player()
	leave_arena_if_needed()
