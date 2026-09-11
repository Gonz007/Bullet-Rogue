extends Control

const CARDS: Array[CardData] = [
	preload("res://cards/double_shot.tres"), preload("res://cards/triple_shot.tres"), preload("res://cards/pierce.tres"),
	preload("res://cards/split.tres"), preload("res://cards/bounce.tres"), preload("res://cards/combustion.tres"),
	preload("res://cards/rocket.tres"), preload("res://cards/parry_reflector.tres"), preload("res://cards/counter_shot.tres"), preload("res://cards/overload.tres"),
	preload("res://cards/boss_prism.tres"), preload("res://cards/boss_singularity.tres"), preload("res://cards/boss_bulwark.tres"),
	preload("res://cards/boss_rail.tres"), preload("res://cards/boss_nova.tres"), preload("res://cards/boss_chaos_drive.tres")
]


func _ready() -> void:
	$Layout/Tabs/Cards.pressed.connect(_show_cards)
	$Layout/Tabs/Synergies.pressed.connect(_show_synergies)
	$Layout/Back.pressed.connect(hide)
	_show_cards()


func _show_cards() -> void:
	_clear_entries()
	$Layout/Title.text = "CARD COLLECTION"
	for card in CARDS:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if card.is_boss_card and not SaveManager.is_boss_card_unlocked(card.id):
			label.text = "???  ·  BOSS RELIC\nDefeat %s to reveal this card." % card.boss_id.to_upper()
			label.modulate = Color(0.42, 0.45, 0.55)
		else:
			label.text = "%s  ·  %s\n%s" % [card.display_name.to_upper(), CardData.Rarity.keys()[card.rarity], card.description]
			label.modulate = Color(0.35, 0.85, 1.0) if not card.is_boss_card else Color(1.0, 0.72, 0.28)
		$Layout/Scroll/Entries.add_child(label)


func _show_synergies() -> void:
	_clear_entries()
	$Layout/Title.text = "SYNERGY COLLECTION"
	for synergy in SynergyManager.CATALOG:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if SaveManager.is_synergy_discovered(synergy.id):
			label.text = "%s\n%s" % [synergy.display_name, synergy.description]
			label.modulate = Color(0.45, 0.95, 1.0)
		else:
			label.text = "???\nDiscover this combination during a run."
			label.modulate = Color(0.42, 0.45, 0.55)
		$Layout/Scroll/Entries.add_child(label)


func _clear_entries() -> void:
	for child in $Layout/Scroll/Entries.get_children():
		child.queue_free()
