class_name StraightShooter
extends Shooter

func _fire_at_player() -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	projectile.global_position = global_position + Vector2(0, 24)
	get_tree().current_scene.add_child(projectile)
	projectile.configure(Projectile.Team.ENEMY, Vector2.DOWN, 1, projectile_speed, self)
