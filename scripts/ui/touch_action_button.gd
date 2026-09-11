class_name TouchActionButton
extends Button

@export var input_action := "move_left"


func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	button_down.connect(_send_pressed.bind(true))
	button_up.connect(_send_pressed.bind(false))
	mouse_exited.connect(_release_if_held)


func _send_pressed(pressed: bool) -> void:
	var action_event := InputEventAction.new()
	action_event.action = input_action
	action_event.pressed = pressed
	Input.parse_input_event(action_event)


func _release_if_held() -> void:
	if button_pressed:
		_send_pressed(false)
