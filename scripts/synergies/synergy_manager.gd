extends Node

signal synergies_changed(active_synergies: Array[SynergyData])
signal synergy_unlocked(synergy: SynergyData)

const CATALOG: Array[SynergyData] = [
	preload("res://synergies/strike_drones.tres"), preload("res://synergies/twin_lance.tres"),
	preload("res://synergies/ricochet_fan.tres"), preload("res://synergies/cluster_bomb.tres"),
	preload("res://synergies/mirror_fracture.tres"), preload("res://synergies/counter_bomb.tres"),
	preload("res://synergies/twin_missiles.tres"), preload("res://synergies/warhead.tres"),
	preload("res://synergies/retaliation_fan.tres"), preload("res://synergies/pinball.tres")
]

var _active_synergies: Array[SynergyData] = []


func recalculate(cards: Array[CardData]) -> void:
	var next_active: Array[SynergyData] = []
	for synergy in CATALOG:
		if synergy.is_satisfied_by(cards):
			next_active.append(synergy)
			if not _active_synergies.any(func(active: SynergyData) -> bool: return active.id == synergy.id):
				SaveManager.mark_synergy_discovered(synergy.id)
				synergy_unlocked.emit(synergy)
	_active_synergies = next_active
	synergies_changed.emit(_active_synergies)


func get_active_synergies() -> Array[SynergyData]:
	return _active_synergies.duplicate()


func has_synergy(synergy_id: String) -> bool:
	return _active_synergies.any(func(synergy: SynergyData) -> bool: return synergy.id == synergy_id)


func on_combat_event(event_name: String, context: Dictionary, card_manager: CardManager) -> void:
	if event_name == "before_shot":
		if has_synergy("twin_lance"):
			context["directions"] = [Vector2.UP.rotated(-0.055), Vector2.UP.rotated(0.055)]
			context["tags"].append("twin_lance")
		elif has_synergy("ricochet_fan"):
			context["directions"] = [Vector2.UP.rotated(-0.24), Vector2.UP, Vector2.UP.rotated(0.24)]
			context["tags"].append("ricochet_fan")
		elif has_synergy("retaliation_fan") and context.get("metadata", {}).get("counter_shot", false):
			context["directions"] = [Vector2.UP.rotated(-0.28), Vector2.UP, Vector2.UP.rotated(0.28)]
	if event_name == "projectile_spawned":
		var projectile := context["projectile"] as Projectile
		if projectile == null:
			return
		if has_synergy("twin_lance"):
			projectile.pierce_remaining += 1
		if has_synergy("pinball"):
			projectile.bounces_remaining += 1
	if event_name == "projectile_reflected" and has_synergy("mirror_fracture"):
		var reflected := context["projectile"] as Projectile
		if reflected != null:
			card_manager.spawn_player_projectiles(reflected.global_position, [reflected.direction.rotated(-0.22), reflected.direction.rotated(0.22)], reflected.damage_info.amount, reflected.speed, {"mirror_fracture": true})
	if event_name == "projectile_hit":
		var impact_projectile := context["projectile"] as Projectile
		if impact_projectile == null:
			return
		if has_synergy("counter_bomb") and impact_projectile.metadata.get("reflected", false):
			CombatEffect.spawn(impact_projectile.get_tree().current_scene, impact_projectile.global_position, Color(0.35, 0.95, 1.0), 58.0)
		if has_synergy("cluster_bomb") and impact_projectile.metadata.get("split_generation", 0) > 0:
			card_manager.spawn_player_projectiles(impact_projectile.global_position, [Vector2.UP.rotated(-0.55), Vector2.UP.rotated(0.55)], 1, impact_projectile.speed * 0.75, {"cluster_fragment": true})
