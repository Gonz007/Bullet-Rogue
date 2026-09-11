class_name Shooter
extends Enemy

@export var projectile_scene: PackedScene
@export var descent_speed := 58.0
@export var hold_y := 220.0
@export var fire_interval := 1.65
@export var projectile_speed := 195.0

var _fire_time := 0.65


func _physics_process(delta: float) -> void:
	if global_position.y < hold_y:
		global_position.y += descent_speed * delta
	_fire_time -= delta
	if _fire_time <= 0.0:
		_fire_time = fire_interval
		_fire_at_player()
	leave_arena_if_needed()


func _fire_at_player() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	projectile.global_position = global_position + Vector2(0, 24)
	get_tree().current_scene.add_child(projectile)
	projectile.configure(Projectile.Team.ENEMY, (player.global_position - global_position).normalized(), 1, projectile_speed, self)
