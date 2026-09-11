class_name BossRewardData
extends RefCounted

static func get_cards(boss_id: String) -> Array[CardData]:
	match boss_id:
		"boss_1":
			return [preload("res://cards/boss_prism.tres"), preload("res://cards/boss_singularity.tres")]
		"boss_2":
			return [preload("res://cards/boss_bulwark.tres"), preload("res://cards/boss_rail.tres")]
	return []
