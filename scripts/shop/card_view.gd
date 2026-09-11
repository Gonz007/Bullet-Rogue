class_name CardView
extends Button

signal card_pressed(card_view: CardView)

const RARITY_COLORS := [Color(0.78, 0.82, 0.9), Color(0.28, 0.76, 1.0), Color(0.72, 0.4, 1.0), Color(1.0, 0.75, 0.2)]

var card: CardData
var slot_index := -1
var _compact := false


func _ready() -> void:
	pressed.connect(func() -> void: card_pressed.emit(self))
	_apply_style(Color(0.2, 0.45, 0.65), false)


func display_card(value: CardData, compact := false, index := -1) -> void:
	card = value
	slot_index = index
	_compact = compact
	$Content/Icon.color = Color(0.2, 0.35, 0.48) if card == null else RARITY_COLORS[card.rarity]
	if card == null:
		$Content/Name.text = "EMPTY"
		$Content/Rarity.text = "OPEN SLOT"
		$Content/Description.text = ""
		_apply_style(Color(0.22, 0.28, 0.36), false)
	else:
		$Content/Name.text = card.display_name.to_upper()
		$Content/Rarity.text = CardData.Rarity.keys()[card.rarity]
		$Content/Description.text = "" if compact else card.description
		_apply_style(RARITY_COLORS[card.rarity], false)
	$Content/Description.visible = not compact
	disabled = compact and card == null


func set_selectable(value: bool) -> void:
	disabled = not value
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if value else Control.CURSOR_ARROW


func set_selected(value: bool) -> void:
	var color: Color = Color(1.0, 0.78, 0.22) if value else (RARITY_COLORS[card.rarity] if card != null else Color(0.22, 0.28, 0.36))
	_apply_style(color, value)


func _apply_style(accent: Color, selected: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.035, 0.06, 0.11, 0.98) if not selected else Color(0.09, 0.12, 0.18, 1)
	normal.border_color = accent
	normal.set_border_width_all(3 if selected else 1)
	normal.set_corner_radius_all(6)
	normal.content_margin_left = 6
	normal.content_margin_right = 6
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	var hover := normal.duplicate()
	hover.border_color = Color(0.82, 0.96, 1.0) if not selected else accent
	hover.set_border_width_all(3)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
