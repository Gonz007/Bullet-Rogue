class_name TurretEnemy
extends Enemy

enum Pattern { AIMED, BURST, ALTERNATING }

@export var projectile_scene: PackedScene
@export var pattern := Pattern.ALTERNATING
@export var horizontal_speed := 115.0
@export var left_limit := 48.0
@export var right_limit := 432.0
@export var fire_interval := 1.5
@export var burst_count := 5
@export var burst_spread_degrees := 62.0
@export var projectile_speed := 200.0

var _moving_right := true
var _fire_time := 0.9
var _next_pattern := Pattern.AIMED


func _physics_process(delta: float) -> void:
	global_position.x += horizontal_speed * delta * (1.0 if _moving_right else -1.0)
	if global_position.x >= right_limit:
		global_position.x = right_limit
		_moving_right = false
	elif global_position.x <= left_limit:
		global_position.x = left_limit
		_moving_right = true
	_fire_time -= delta
	if _fire_time <= 0.0:
		_fire_time = fire_interval
		_fire_pattern()


func get_spawn_position(random: RandomNumberGenerator) -> Vector2:
	return Vector2(random.randf_range(left_limit, right_limit), 105.0)


func _fire_pattern() -> void:
	var selected_pattern := pattern
	if pattern == Pattern.ALTERNATING:
		selected_pattern = _next_pattern
		_next_pattern = Pattern.BURST if _next_pattern == Pattern.AIMED else Pattern.AIMED
	if selected_pattern == Pattern.AIMED:
		_fire_aimed()
	else:
		_fire_burst()


func _fire_aimed() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	_spawn_projectile((player.global_position - global_position).normalized())


func _fire_burst() -> void:
	for index in burst_count:
		var ratio := 0.5 if burst_count == 1 else float(index) / float(burst_count - 1)
		var angle := deg_to_rad(lerpf(-burst_spread_degrees / 2.0, burst_spread_degrees / 2.0, ratio))
		_spawn_projectile(Vector2.DOWN.rotated(angle))


func _spawn_projectile(shot_direction: Vector2) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	projectile.global_position = global_position + Vector2(0, 28)
	get_tree().current_scene.add_child(projectile)
	projectile.configure(Projectile.Team.ENEMY, shot_direction, 1, projectile_speed, self)
