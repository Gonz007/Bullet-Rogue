class_name StageSelect
extends Control

signal closed

@onready var _buttons: Array[Button] = [$Layout/Stage1, $Layout/Stage2, $Layout/Stage3]


func _ready() -> void:
	for index in _buttons.size():
		var stage := StageManager.get_stages()[index]
		var unlocked := SaveManager.is_stage_unlocked(stage.id)
		_buttons[index].disabled = not unlocked
		_buttons[index].text = "%s\n%s" % [stage.display_name, stage.description if unlocked else "LOCKED — " + stage.unlock_requirement]
		_buttons[index].pressed.connect(func() -> void: _start_stage(stage.id))
	$Layout/Back.pressed.connect(func() -> void:
		hide()
		closed.emit())


func open() -> void:
	for index in _buttons.size():
		var stage := StageManager.get_stages()[index]
		var unlocked := SaveManager.is_stage_unlocked(stage.id)
		_buttons[index].disabled = not unlocked
		_buttons[index].text = "%s\n%s" % [stage.display_name, stage.description if unlocked else "LOCKED — " + stage.unlock_requirement]
	show()


func _start_stage(stage_id: String) -> void:
	if StageManager.select_stage(stage_id):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
