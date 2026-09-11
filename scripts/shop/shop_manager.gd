class_name ShopManager
extends Node

signal shop_requested(offers: Array[CardData])

@export var card_catalog: Array[CardData] = []
@export var rarity_weights := [60.0, 25.0, 11.0, 4.0]

var _card_manager: CardManager
var _random := RandomNumberGenerator.new()


func configure(card_manager: CardManager) -> void:
	_card_manager = card_manager
	_random.randomize()


func request_shop(player_level: int) -> void:
	shop_requested.emit(get_shop_cards(player_level, 3))


func get_shop_cards(player_level: int, amount: int) -> Array[CardData]:
	var candidates: Array[CardData] = []
	for card in card_catalog:
		if _card_manager.get_card_state(card) == CardData.State.UNLOCKED and not _card_manager.has_card(card.id):
			candidates.append(card)
	var offers: Array[CardData] = []
	while offers.size() < amount and not candidates.is_empty():
		var card := _pick_weighted(candidates, player_level)
		offers.append(card)
		candidates.erase(card)
	return offers


func _pick_weighted(candidates: Array[CardData], player_level: int) -> CardData:
	var total_weight := 0.0
	for card in candidates:
		total_weight += _weight_for(card, player_level)
	var roll := _random.randf_range(0.0, total_weight)
	for card in candidates:
		roll -= _weight_for(card, player_level)
		if roll <= 0.0:
			return card
	return candidates.back()


func _weight_for(card: CardData, player_level: int) -> float:
	var weight: float = float(rarity_weights[card.rarity])
	# A small level-based nudge; rarity configuration remains centralized here.
	if player_level >= 10 and card.rarity >= CardData.Rarity.EPIC:
		weight *= 1.5
	elif player_level >= 5 and card.rarity == CardData.Rarity.RARE:
		weight *= 1.25
	return weight
