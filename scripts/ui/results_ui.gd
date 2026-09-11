class_name ResultsUI
extends Control

signal retry_requested
signal main_menu_requested


func _ready() -> void:
	$Center/Panel/Layout/Retry.pressed.connect(func() -> void:
		get_tree().paused = false
		retry_requested.emit())
	$Center/Panel/Layout/MainMenu.pressed.connect(func() -> void:
		get_tree().paused = false
		main_menu_requested.emit())


func open_results(stats: RunStats, level: int, victory: bool, boss_id: String) -> void:
	$Center/Panel/Layout/Title.text = "STAGE COMPLETE" if victory else "RUN OVER"
	$Center/Panel/Layout/Summary.text = "TIME  %02d:%02d\nKILLS  %d\nLEVEL  %d\nBOSS  %s\nSYNERGIES  %d" % [stats.elapsed_seconds() / 60, stats.elapsed_seconds() % 60, stats.kills, level, boss_id.to_upper() if not boss_id.is_empty() else "NONE", SynergyManager.get_active_synergies().size()]
	visible = true
	get_tree().paused = true
