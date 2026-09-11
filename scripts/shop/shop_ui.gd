class_name ShopUI
extends Control

signal closed

@onready var _offer_views: Array[CardView] = [$Center/Panel/Margin/Layout/Offers/Offer1, $Center/Panel/Margin/Layout/Offers/Offer2, $Center/Panel/Margin/Layout/Offers/Offer3]
@onready var _current_views: Array[CardView] = [$Center/Panel/Margin/Layout/CurrentCards/Current1, $Center/Panel/Margin/Layout/CurrentCards/Current2, $Center/Panel/Margin/Layout/CurrentCards/Current3]
@onready var _instruction: Label = $Center/Panel/Margin/Layout/Instruction
@onready var _replace_hint: Label = $Center/Panel/Margin/Layout/ReplaceHint

var _card_manager: CardManager
var _card_slots_hud: CardSlotsHud
var _offers: Array[CardData] = []
var _pending_card: CardData
var _is_boss_reward := false


func _ready() -> void:
	for view in _offer_views:
		view.card_pressed.connect(_on_offer_view_pressed)
	for view in _current_views:
		view.card_pressed.connect(_on_current_view_pressed)
	$Center/Panel/Margin/Layout/Skip.pressed.connect(_on_skip_pressed)


func configure(card_manager: CardManager, card_slots_hud: CardSlotsHud) -> void:
	_card_manager = card_manager
	_card_slots_hud = card_slots_hud
	_card_manager.cards_changed.connect(_refresh_current_cards)


func open_shop(offers: Array[CardData]) -> void:
	_is_boss_reward = false
	$Center/Panel/Margin/Layout/LevelUp.visible = true
	$Center/Panel/Margin/Layout/ShopTitle.text = "SHOP"
	$Center/Panel/Margin/Layout/Skip.visible = true
	_open_cards(offers)


func open_boss_reward(offers: Array[CardData]) -> void:
	_is_boss_reward = true
	$Center/Panel/Margin/Layout/LevelUp.visible = false
	$Center/Panel/Margin/Layout/ShopTitle.text = "BOSS DEFEATED — CHOOSE ONE RELIC"
	$Center/Panel/Margin/Layout/Skip.visible = false
	_open_cards(offers)


func _open_cards(offers: Array[CardData]) -> void:
	_offers = offers
	_pending_card = null
	_instruction.text = "CHOOSE A NEW CARD"
	_replace_hint.visible = false
	for index in _offer_views.size():
		var view := _offer_views[index]
		view.visible = index < offers.size()
		if index < offers.size():
			view.display_card(offers[index])
			view.set_selectable(true)
			view.set_selected(false)
	_refresh_current_cards(_card_manager.get_cards())
	_set_current_selectable(false)
	_card_slots_hud.set_replacement_mode(false)
	visible = true
	get_tree().paused = true


func _on_offer_view_pressed(view: CardView) -> void:
	if view.card == null or _card_manager == null:
		return
	_pending_card = view.card
	AudioManager.play_sfx("card_selected")
	for offer_view in _offer_views:
		offer_view.set_selected(offer_view == view)
	if _card_manager.has_space():
		_card_manager.add_card(_pending_card)
		_unlock_reward_if_needed()
		_close_shop()
		return
	_instruction.text = "CHOOSE A CARD TO REPLACE"
	_replace_hint.visible = true
	_set_current_selectable(true)


func _on_current_view_pressed(view: CardView) -> void:
	if _pending_card == null or view.slot_index < 0:
		return
	if _card_manager.replace_card(view.slot_index, _pending_card):
		_unlock_reward_if_needed()
		_close_shop()


func _refresh_current_cards(cards: Array[CardData]) -> void:
	for index in _current_views.size():
		var card: CardData = cards[index] if index < cards.size() else null
		_current_views[index].display_card(card, true, index)


func _set_current_selectable(enabled: bool) -> void:
	for view in _current_views:
		view.set_selectable(enabled and view.card != null)


func _on_skip_pressed() -> void:
	_close_shop()


func _close_shop() -> void:
	_card_slots_hud.set_replacement_mode(false)
	visible = false
	get_tree().paused = false
	closed.emit()


func _unlock_reward_if_needed() -> void:
	if _is_boss_reward and _pending_card != null:
		_card_manager.unlock_boss_card(_pending_card)
