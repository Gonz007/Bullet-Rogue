class_name BurstEnemy
extends Enemy

@export var projectile_scene: PackedScene
@export var descent_speed := 45.0
@export var hold_y := 145.0
@export var burst_interval := 2.9
@export var burst_count := 5
@export var spread_degrees := 72.0
@export var projectile_speed := 165.0

var _burst_time := 1.4


func _physics_process(delta: float) -> void:
	if global_position.y < hold_y:
		global_position.y += descent_speed * delta
	_burst_time -= delta
	if _burst_time <= 0.0:
		_burst_time = burst_interval
		_fire_burst()
	leave_arena_if_needed()


func _fire_burst() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or projectile_scene == null:
		return
	var base_direction := (player.global_position - global_position).normalized()
	for index in burst_count:
		var ratio := 0.5 if burst_count == 1 else float(index) / float(burst_count - 1)
		var angle := deg_to_rad(lerpf(-spread_degrees / 2.0, spread_degrees / 2.0, ratio))
		var projectile := projectile_scene.instantiate() as Projectile
		projectile.global_position = global_position + Vector2(0, 24)
		get_tree().current_scene.add_child(projectile)
		projectile.configure(Projectile.Team.ENEMY, base_direction.rotated(angle), 1, projectile_speed, self)
