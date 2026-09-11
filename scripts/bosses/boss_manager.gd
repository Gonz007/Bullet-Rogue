class_name BossManager
extends Node

signal boss_started(boss: Boss)
signal boss_health_changed(current: int, maximum: int)
signal boss_phase_changed(phase: int, phase_count: int)
signal boss_defeated(boss_id: String)

var active_boss: Boss
var is_boss_active := false


func start_boss(boss_scene: PackedScene) -> bool:
	if is_boss_active or boss_scene == null:
		return false
	_stop_director_and_clear_arena()
	active_boss = boss_scene.instantiate() as Boss
	if active_boss == null:
		return false
	get_parent().add_child(active_boss)
	active_boss.global_position = Vector2(240.0, 150.0)
	active_boss.health_updated.connect(func(current: int, maximum: int) -> void: boss_health_changed.emit(current, maximum))
	active_boss.phase_changed.connect(func(phase: int, count: int) -> void: boss_phase_changed.emit(phase, count))
	active_boss.defeated.connect(_on_boss_defeated)
	is_boss_active = true
	boss_started.emit(active_boss)
	boss_health_changed.emit(active_boss.health, active_boss.max_health)
	boss_phase_changed.emit(active_boss.current_phase, active_boss.phase_count)
	return true


func _stop_director_and_clear_arena() -> void:
	var director := get_parent().get_node_or_null("EnemySpawner")
	if director != null and director.has_method("set_active"):
		director.set_active(false)
	for enemy_node in get_tree().get_nodes_in_group("enemies"):
		enemy_node.queue_free()
	for projectile_node in get_tree().get_nodes_in_group("projectiles"):
		var projectile := projectile_node as Projectile
		if projectile != null and projectile.team == Projectile.Team.ENEMY:
			projectile.queue_free()


func _on_boss_defeated(boss: Boss, _damage_info: DamageInfo) -> void:
	is_boss_active = false
	boss_defeated.emit(boss.boss_id)
