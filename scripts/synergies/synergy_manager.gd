extends Node

signal synergies_changed(active_synergies: Array[SynergyData])
signal synergy_unlocked(synergy: SynergyData)

const CATALOG: Array[SynergyData] = [preload("res://synergies/strike_drones.tres")]

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
