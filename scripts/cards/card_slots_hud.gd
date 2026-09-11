class_name CardSlotsHud
extends Control

signal slot_selected(slot_index: int)

const RARITY_COLORS := [Color(0.75, 0.75, 0.75), Color(0.38, 0.72, 1.0), Color(0.75, 0.38, 1.0), Color(1.0, 0.72, 0.2)]

var _slots: Array[Label]
var _slot_buttons: Array[Button]
var _current_cards: Array[CardData] = []


func _ready() -> void:
	_slots.assign([$Slot1, $Slot2, $Slot3])
	_slot_buttons.assign([$Slot1Button, $Slot2Button, $Slot3Button])
	for index in _slot_buttons.size():
		_slot_buttons[index].pressed.connect(func() -> void: slot_selected.emit(index))
	show_cards([])
	set_replacement_mode(false)


func show_cards(cards: Array[CardData]) -> void:
	if _slots.is_empty():
		return
	_current_cards = cards.duplicate()
	for index in _slots.size():
		var label := _slots[index]
		if index < cards.size():
			var card := cards[index]
			label.text = "%s\n%s" % [card.display_name.to_upper(), CardData.Rarity.keys()[card.rarity]]
			label.modulate = RARITY_COLORS[card.rarity]
			label.tooltip_text = card.description
		else:
			label.text = "EMPTY"
			label.modulate = Color(0.45, 0.48, 0.55)
			label.tooltip_text = "Empty card slot"


func set_replacement_mode(enabled: bool) -> void:
	for index in _slot_buttons.size():
		_slot_buttons[index].disabled = not enabled
		_slot_buttons[index].visible = enabled
		if enabled:
			_slots[index].modulate = Color(1.0, 0.78, 0.25)
	if not enabled:
		show_cards(_current_cards)
