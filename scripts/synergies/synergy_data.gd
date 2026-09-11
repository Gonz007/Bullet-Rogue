class_name SynergyData
extends Resource

@export var id := ""
@export var display_name := ""
@export_multiline var description := ""
@export var required_card_ids: Array[String] = []
@export var effect_type := ""
@export var parameters: Dictionary = {}


func is_satisfied_by(cards: Array[CardData]) -> bool:
	var equipped_ids: Array[String] = []
	for card in cards:
		equipped_ids.append(card.id)
	return required_card_ids.all(func(card_id: String) -> bool: return equipped_ids.has(card_id))
