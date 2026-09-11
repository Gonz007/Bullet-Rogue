class_name SpreadShooter
extends Shooter

@export var spread_count := 5
@export var spread_degrees := 60.0

func _fire_at_player() -> void:
	if projectile_scene == null:
		return
	for index in spread_count:
		var ratio := 0.5 if spread_count == 1 else float(index) / float(spread_count - 1)
		var angle := deg_to_rad(lerpf(-spread_degrees / 2.0, spread_degrees / 2.0, ratio))
		var projectile := projectile_scene.instantiate() as Projectile
		projectile.global_position = global_position + Vector2(0, 24)
		get_tree().current_scene.add_child(projectile)
		projectile.configure(Projectile.Team.ENEMY, Vector2.DOWN.rotated(angle), 1, projectile_speed, self)
