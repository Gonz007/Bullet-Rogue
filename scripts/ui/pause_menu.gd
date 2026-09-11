class_name PauseMenu
extends Control

signal restart_requested
signal main_menu_requested

var _confirmation_mode := ""

func _ready() -> void:
	$Panel/Layout/Resume.pressed.connect(close_menu)
	$Panel/Layout/Settings.pressed.connect(func() -> void: $Settings.visible = true)
	$Panel/Layout/Restart.pressed.connect(func() -> void: _ask_confirmation("restart"))
	$Panel/Layout/MainMenu.pressed.connect(func() -> void: _ask_confirmation("menu"))
	$Panel/Layout/ConfirmRow/Cancel.pressed.connect(_clear_confirmation)
	$Panel/Layout/ConfirmRow/Confirm.pressed.connect(_confirm)
	$Settings.closed.connect(func() -> void: $Settings.visible = false)
	$Panel/Layout/ConfirmRow.visible = false


func open_menu() -> void:
	if visible:
		return
	visible = true
	get_tree().paused = true


func close_menu() -> void:
	_clear_confirmation()
	visible = false
	get_tree().paused = false


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func _ask_confirmation(mode: String) -> void:
	_confirmation_mode = mode
	$Panel/Layout/ConfirmRow.visible = true
	$Panel/Layout/ConfirmRow/Prompt.text = "RESTART CURRENT RUN?" if mode == "restart" else "RETURN TO MAIN MENU? RUN WILL BE LOST."


func _clear_confirmation() -> void:
	_confirmation_mode = ""
	$Panel/Layout/ConfirmRow.visible = false


func _confirm() -> void:
	var mode := _confirmation_mode
	close_menu()
	if mode == "restart":
		restart_requested.emit()
	elif mode == "menu":
		main_menu_requested.emit()
