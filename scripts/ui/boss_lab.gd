extends Control

const BOSS_SCENES: Array[PackedScene] = [
	preload("res://scenes/bosses/GeometryBoss.tscn"),
	preload("res://scenes/bosses/CorridorBoss.tscn"),
	preload("res://scenes/bosses/ChaosBoss.tscn")
]


func _ready() -> void:
	var buttons: Array[Button] = [$Layout/Boss1, $Layout/Boss2, $Layout/Boss3]
	for index in buttons.size():
		buttons[index].disabled = false
		buttons[index].text = "TEST BOSS %d" % (index + 1)
		buttons[index].pressed.connect(func() -> void: _launch(index))


func _launch(index: int) -> void:
	StageManager.begin_boss_test(BOSS_SCENES[index])
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
