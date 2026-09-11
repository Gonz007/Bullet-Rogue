class_name CardEffect
extends Resource

enum Kind { DOUBLE_SHOT, TRIPLE_SHOT, PIERCE, SPLIT, BOUNCE, COMBUSTION, REFLECTOR, COUNTER_SHOT, ROCKET, OVERLOAD }

@export var kind := Kind.DOUBLE_SHOT
@export var value := 1.0

var _counter := 0
var _timer := 0.0
var _counter_shot_ready := false


func reset_runtime() -> void:
	_counter = 0
	_timer = 0.0
	_counter_shot_ready = false


func on_event(event_name: String, context: Dictionary, manager: CardManager) -> void:
	match kind:
		Kind.DOUBLE_SHOT:
			if event_name == "before_shot":
				context["directions"] = [Vector2.UP.rotated(-0.10), Vector2.UP.rotated(0.10)]
		Kind.TRIPLE_SHOT:
			if event_name == "before_shot":
				context["directions"] = [Vector2.UP.rotated(-0.16), Vector2.UP, Vector2.UP.rotated(0.16)]
		Kind.PIERCE:
			if event_name == "projectile_spawned":
				(context["projectile"] as Projectile).pierce_remaining += int(value)
		Kind.SPLIT:
			if event_name == "projectile_hit":
				var projectile := context["projectile"] as Projectile
				if projectile.metadata.get("split_generation", 0) < 1:
					var metadata := projectile.metadata.duplicate()
					metadata["split_generation"] = 1
					manager.spawn_player_projectiles(projectile.global_position, [projectile.direction.rotated(-0.32), projectile.direction.rotated(0.32)], projectile.damage_info.amount, projectile.speed * 0.82, metadata)
		Kind.BOUNCE:
			if event_name == "projectile_spawned":
				(context["projectile"] as Projectile).bounces_remaining += int(value)
		Kind.COMBUSTION:
			if event_name == "projectile_hit":
				_explode(context["projectile"] as Projectile)
		Kind.REFLECTOR:
			if event_name == "projectile_reflected":
				var projectile := context["projectile"] as Projectile
				projectile.damage_info.amount += int(value)
				projectile.damage_info.tags.append("reflector")
		Kind.COUNTER_SHOT:
			if event_name == "projectile_reflected":
				_counter_shot_ready = true
			elif event_name == "before_shot" and _counter_shot_ready:
				context["damage"] += int(value)
				context["tags"].append("counter_shot")
				context["metadata"]["counter_shot"] = true
				_counter_shot_ready = false
		Kind.ROCKET:
			if event_name == "tick":
				_timer -= context["delta"]
				if _timer <= 0.0:
					_timer = value
					manager.spawn_rocket()
		Kind.OVERLOAD:
			if event_name == "projectile_fired":
				_counter += 1
				if _counter >= 12:
					_counter = 0
					_timer = 3.5
			elif event_name == "tick":
				_timer = maxf(0.0, _timer - context["delta"])
			elif event_name == "modify_fire_interval" and _timer > 0.0:
				context["interval"] *= 0.62


func _explode(projectile: Projectile) -> void:
	CombatEffect.spawn(projectile.get_tree().current_scene, projectile.global_position, Color(1.0, 0.55, 0.16), 42.0)
	for enemy_node in projectile.get_tree().get_nodes_in_group("enemies"):
		var enemy := enemy_node as Enemy
		if enemy != null and enemy.global_position.distance_to(projectile.global_position) <= 42.0:
			var damage_info := DamageInfo.new()
			damage_info.amount = 1
			damage_info.team = Projectile.Team.PLAYER
			damage_info.tags = ["combustion"]
			enemy.take_damage(damage_info)
