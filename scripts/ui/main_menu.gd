extends Control

func _ready() -> void:
	$Center/Layout/Play.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/Main.tscn"))
	$Center/Layout/Cards.pressed.connect(func() -> void: $CollectionNotice.visible = true)
	$Center/Layout/Settings.pressed.connect(func() -> void: $Settings.visible = true)
	$Center/Layout/Quit.pressed.connect(func() -> void: get_tree().quit())
	$Settings.closed.connect(func() -> void: $Settings.visible = false)
