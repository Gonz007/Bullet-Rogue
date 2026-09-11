class_name SciFiButton
extends Button

func _ready() -> void:
	var normal := _style(Color(0.035, 0.07, 0.12, 0.96), Color(0.24, 0.64, 0.9), 1)
	var hover := _style(Color(0.08, 0.15, 0.23, 1), Color(0.45, 0.9, 1.0), 2)
	var pressed_style := _style(Color(0.12, 0.22, 0.31, 1), Color(1.0, 0.76, 0.25), 2)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed_style)


func _style(background: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(5)
	return style
