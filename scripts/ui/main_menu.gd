extends Control

func _ready() -> void:
	$Center/Layout/Play.pressed.connect(func() -> void: $StageSelect.open())
	$Center/Layout/Cards.pressed.connect(func() -> void: $Collection.show())
	$Center/Layout/Hangar.pressed.connect(func() -> void: $Hangar.visible = true)
	$Center/Layout/BossLab.pressed.connect(func() -> void: $BossLab.visible = true)
	$Center/Layout/Settings.pressed.connect(func() -> void: $Settings.visible = true)
	$Center/Layout/Quit.pressed.connect(func() -> void: get_tree().quit())
	$Settings.closed.connect(func() -> void: $Settings.visible = false)
	$Hangar.hide()
	$BossLab/Layout/Back.pressed.connect(func() -> void: $BossLab.hide())
	$StageSelect.closed.connect(func() -> void: $StageSelect.hide())
	$Collection.hide()
