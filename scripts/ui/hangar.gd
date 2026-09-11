extends Control

var _selected: SkinData

func _ready() -> void:
	$Panel/Layout/Back.pressed.connect(func() -> void: hide())
	$Panel/Layout/BuyEquip.pressed.connect(_on_buy_equip)
	$Panel/Layout/SkinList.item_selected.connect(_on_skin_selected)
	SkinManager.coins_changed.connect(func(_total: int) -> void: _refresh())
	_rebuild_list()


func _rebuild_list() -> void:
	$Panel/Layout/SkinList.clear()
	for skin in SkinManager.get_skins():
		$Panel/Layout/SkinList.add_item("%s  —  %s" % [skin.display_name, "OWNED" if SkinManager.is_purchased(skin) else "%d COINS" % skin.price])
	$Panel/Layout/SkinList.select(0)
	_selected = SkinManager.get_skins()[0]
	_refresh()


func _on_skin_selected(index: int) -> void:
	_selected = SkinManager.get_skins()[index]
	_refresh()


func _refresh() -> void:
	if _selected == null:
		return
	$Panel/Layout/Coins.text = "STAR COINS: %d" % SaveManager.get_coins()
	$Panel/Layout/Preview.color = _selected.ship_color
	$Panel/Layout/Name.text = _selected.display_name.to_upper()
	$Panel/Layout/Description.text = _selected.description
	var owned := SkinManager.is_purchased(_selected)
	var equipped := SaveManager.get_equipped_skin() == _selected.id
	$Panel/Layout/BuyEquip.text = "EQUIPPED" if equipped else ("EQUIP" if owned else "BUY — %d" % _selected.price)
	$Panel/Layout/BuyEquip.disabled = equipped or (not owned and SaveManager.get_coins() < _selected.price)


func _on_buy_equip() -> void:
	if SkinManager.purchase_or_equip(_selected):
		_refresh()
