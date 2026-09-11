class_name SettingsPanel
extends Control

signal closed

func _ready() -> void:
	$Panel/Layout/Back.pressed.connect(func() -> void: hide(); closed.emit())
	$Panel/Layout/Fullscreen.toggled.connect(_on_fullscreen_toggled)
	$Panel/Layout/Master.value_changed.connect(func(value: float) -> void: _set_bus_volume("Master", value))
	$Panel/Layout/Music.value_changed.connect(func(value: float) -> void: _set_bus_volume("Music", value))
	$Panel/Layout/SFX.value_changed.connect(func(value: float) -> void: _set_bus_volume("SFX", value))
	$Panel/Layout/Fullscreen.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN


func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)


func _set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.001)))
