extends Node

signal skin_changed(skin: SkinData)
signal coins_changed(total: int)

const SKINS: Array[SkinData] = [
	preload("res://skins/default_ship.tres"),
	preload("res://skins/crimson_wing.tres"),
	preload("res://skins/void_runner.tres"),
	preload("res://skins/golden_spear.tres"),
	preload("res://skins/emerald_comet.tres")
]


func _ready() -> void:
	SaveManager.coins_changed.connect(func(total: int) -> void: coins_changed.emit(total))


func get_skins() -> Array[SkinData]:
	return SKINS.duplicate()


func get_skin(skin_id: String) -> SkinData:
	for skin in SKINS:
		if skin.id == skin_id:
			return skin
	return SKINS[0]


func get_equipped_skin() -> SkinData:
	return get_skin(SaveManager.get_equipped_skin())


func is_purchased(skin: SkinData) -> bool:
	return SaveManager.get_purchased_skins().has(skin.id)


func purchase_or_equip(skin: SkinData) -> bool:
	if not is_purchased(skin):
		if not SaveManager.spend_coins(skin.price):
			return false
		SaveManager.set_skin_purchased(skin.id)
	SaveManager.set_equipped_skin(skin.id)
	skin_changed.emit(skin)
	return true
