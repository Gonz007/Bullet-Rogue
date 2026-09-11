class_name SettingsPanel
extends Control

signal closed

func _ready() -> void:
	$Panel/Layout/Master.value = float(SaveManager.get_setting("master_volume", 0.8))
	$Panel/Layout/Music.value = float(SaveManager.get_setting("music_volume", 0.8))
	$Panel/Layout/SFX.value = float(SaveManager.get_setting("sfx_volume", 0.8))
	$Panel/Layout/Fullscreen.button_pressed = bool(SaveManager.get_setting("fullscreen", false))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if $Panel/Layout/Fullscreen.button_pressed else DisplayServer.WINDOW_MODE_WINDOWED)
	$Panel/Layout/Back.pressed.connect(func() -> void: hide(); closed.emit())
	$Panel/Layout/Fullscreen.toggled.connect(_on_fullscreen_toggled)
	$Panel/Layout/Master.value_changed.connect(func(value: float) -> void: _set_bus_volume("Master", value); SaveManager.set_setting("master_volume", value))
	$Panel/Layout/Music.value_changed.connect(func(value: float) -> void: _set_bus_volume("Music", value); SaveManager.set_setting("music_volume", value))
	$Panel/Layout/SFX.value_changed.connect(func(value: float) -> void: _set_bus_volume("SFX", value); SaveManager.set_setting("sfx_volume", value))
	$Panel/Layout/ScreenShake.toggled.connect(SaveManager.set_screen_shake_enabled)
	$Panel/Layout/ScreenShake.button_pressed = SaveManager.is_screen_shake_enabled()
	_set_bus_volume("Master", $Panel/Layout/Master.value)
	_set_bus_volume("Music", $Panel/Layout/Music.value)
	_set_bus_volume("SFX", $Panel/Layout/SFX.value)


func _on_fullscreen_toggled(enabled: bool) -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED)
	SaveManager.set_setting("fullscreen", enabled)


func _set_bus_volume(bus_name: String, value: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(value, 0.001)))
