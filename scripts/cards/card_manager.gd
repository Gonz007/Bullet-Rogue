class_name CardManager
extends Node

signal cards_changed(cards: Array[CardData])
signal card_rejected(card: CardData)

@export var test_cards: Array[CardData] = []

var _cards: Array[CardData] = []
var _permanent_unlocked: Dictionary = {}
var _player: Player
var _weapon: Weapon


func configure(player: Player) -> void:
	_player = player
	_weapon = player.get_node("Weapon") as Weapon
	_weapon.set_card_manager(self)
	player.projectile_parried.connect(_on_projectile_reflected)
	SynergyManager.recalculate(_cards)
	cards_changed.emit(_cards)


func add_card(card: CardData) -> bool:
	if card == null or _cards.size() >= 3 or has_card(card.id):
		card_rejected.emit(card)
		return false
	var runtime_card := card.duplicate(true) as CardData
	if runtime_card.effect != null:
		runtime_card.effect.reset_runtime()
	_cards.append(runtime_card)
	SynergyManager.recalculate(_cards)
	cards_changed.emit(_cards)
	return true


func remove_card(card_id: String) -> bool:
	for index in _cards.size():
		if _cards[index].id == card_id:
			_cards.remove_at(index)
			SynergyManager.recalculate(_cards)
			cards_changed.emit(_cards)
			return true
	return false


func replace_card(slot_index: int, card: CardData) -> bool:
	if card == null or slot_index < 0 or slot_index >= _cards.size() or has_card(card.id):
		return false
	var runtime_card := card.duplicate(true) as CardData
	if runtime_card.effect != null:
		runtime_card.effect.reset_runtime()
	_cards[slot_index] = runtime_card
	SynergyManager.recalculate(_cards)
	cards_changed.emit(_cards)
	return true


func has_space() -> bool:
	return _cards.size() < 3


func has_card(card_id: String) -> bool:
	return _cards.any(func(card: CardData) -> bool: return card.id == card_id)


func get_cards() -> Array[CardData]:
	return _cards.duplicate()


func get_card_state(card: CardData) -> CardData.State:
	if has_card(card.id):
		return CardData.State.OWNED_IN_RUN
	if card.is_boss_card and not _permanent_unlocked.get(card.id, false):
		return CardData.State.LOCKED
	return CardData.State.UNLOCKED


func unlock_boss_card(card: CardData) -> void:
	if card.is_boss_card:
		_permanent_unlocked[card.id] = true


func reset_run_cards() -> void:
	_cards.clear()
	SynergyManager.recalculate(_cards)
	cards_changed.emit(_cards)


func add_test_card(index: int) -> bool:
	if index < 0 or index >= test_cards.size():
		return false
	return add_card(test_cards[index])


func build_shot_context(direction: Vector2, damage: int, speed: float) -> Dictionary:
	var context := {"directions": [direction], "damage": damage, "speed": speed, "tags": [], "metadata": {}}
	_dispatch("before_shot", context)
	return context


func get_fire_interval(base_interval: float) -> float:
	var context := {"interval": base_interval}
	_dispatch("modify_fire_interval", context)
	return context["interval"]


func register_projectile(projectile: Projectile) -> void:
	projectile.impact.connect(_on_projectile_hit)
	projectile.reflected.connect(_on_projectile_reflected)
	_dispatch("projectile_spawned", {"projectile": projectile})
	_dispatch("projectile_fired", {"projectile": projectile})


func spawn_player_projectiles(position: Vector2, directions: Array, damage: int, speed: float, metadata: Dictionary = {}) -> void:
	for shot_direction in directions:
		var projectile := _weapon.projectile_scene.instantiate() as Projectile
		projectile.global_position = position
		get_tree().current_scene.add_child(projectile)
		projectile.configure(Projectile.Team.PLAYER, shot_direction, damage, speed, _player)
		projectile.metadata = metadata.duplicate()
		register_projectile(projectile)


func spawn_rocket() -> void:
	if _player == null or _weapon == null:
		return
	spawn_player_projectiles(_player.get_node("Muzzle").global_position, [Vector2.UP], 3, 420.0, {"rocket": true})


func _process(delta: float) -> void:
	_dispatch("tick", {"delta": delta})


func _on_projectile_hit(projectile: Projectile, target: Node) -> void:
	_dispatch("projectile_hit", {"projectile": projectile, "target": target})


func _on_projectile_reflected(projectile: Projectile) -> void:
	_dispatch("projectile_reflected", {"projectile": projectile})


func _dispatch(event_name: String, context: Dictionary) -> void:
	for card in _cards:
		if card.effect != null:
			card.effect.on_event(event_name, context, self)
