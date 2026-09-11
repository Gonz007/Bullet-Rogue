extends Node

signal coins_changed(total: int)
signal save_loaded

const SAVE_VERSION := 1
const SAVE_PATH := "user://starfall_save.json"

var _data: Dictionary = {}


func _ready() -> void:
	load_save()


func load_save() -> void:
	_data = _default_data()
	if not FileAccess.file_exists(SAVE_PATH):
		save()
		save_loaded.emit()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Unable to read save file; using defaults.")
		save_loaded.emit()
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		_merge_with_defaults(parsed)
	else:
		push_warning("Save data was invalid; using defaults.")
	save_loaded.emit()
	coins_changed.emit(get_coins())


func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to write save file.")
		return
	file.store_string(JSON.stringify(_data, "\t"))


func get_coins() -> int:
	return int(_data.get("coins", 0))


func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	_data["coins"] = get_coins() + amount
	save()
	coins_changed.emit(get_coins())


func spend_coins(amount: int) -> bool:
	if amount < 0 or get_coins() < amount:
		return false
	_data["coins"] = get_coins() - amount
	save()
	coins_changed.emit(get_coins())
	return true


func get_purchased_skins() -> Array:
	return _data.get("purchased_skins", []).duplicate()


func set_skin_purchased(skin_id: String) -> void:
	var skins: Array = _data.get("purchased_skins", [])
	if not skins.has(skin_id):
		skins.append(skin_id)
		_data["purchased_skins"] = skins
		save()


func get_equipped_skin() -> String:
	return str(_data.get("equipped_skin", "default_ship"))


func set_equipped_skin(skin_id: String) -> void:
	_data["equipped_skin"] = skin_id
	save()


func is_boss_card_unlocked(card_id: String) -> bool:
	return _data.get("unlocked_boss_cards", []).has(card_id)


func unlock_boss_card(card_id: String) -> void:
	_append_unique("unlocked_boss_cards", card_id)


func is_stage_unlocked(stage_id: String) -> bool:
	return _data.get("unlocked_stages", []).has(stage_id)


func unlock_stage(stage_id: String) -> void:
	_append_unique("unlocked_stages", stage_id)


func mark_boss_defeated(boss_id: String) -> void:
	_append_unique("defeated_bosses", boss_id)


func add_boss_token(token_id: String) -> void:
	_append_unique("boss_tokens", token_id)


func mark_synergy_discovered(synergy_id: String) -> void:
	_append_unique("discovered_synergies", synergy_id)


func _append_unique(key: String, value: String) -> void:
	var values: Array = _data.get(key, [])
	if not values.has(value):
		values.append(value)
		_data[key] = values
		save()


func _default_data() -> Dictionary:
	return {
		"save_version": SAVE_VERSION,
		"coins": 0,
		"purchased_skins": ["default_ship"],
		"equipped_skin": "default_ship",
		"unlocked_boss_cards": [],
		"defeated_bosses": [],
		"unlocked_stages": ["stage_1"],
		"boss_tokens": [],
		"discovered_synergies": []
	}


func _merge_with_defaults(loaded: Dictionary) -> void:
	for key in _default_data():
		_data[key] = loaded.get(key, _default_data()[key])
	_data["save_version"] = SAVE_VERSION
