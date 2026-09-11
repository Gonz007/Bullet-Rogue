extends Node

const STAGES: Array[StageData] = [
	preload("res://stages/stage_1.tres"),
	preload("res://stages/stage_2.tres"),
	preload("res://stages/stage_3.tres")
]

var selected_stage_id := "stage_1"
var pending_boss_test: PackedScene


func get_stages() -> Array[StageData]:
	return STAGES.duplicate()


func get_stage(stage_id: String = selected_stage_id) -> StageData:
	for stage in STAGES:
		if stage.id == stage_id:
			return stage
	return STAGES[0]


func select_stage(stage_id: String) -> bool:
	if not SaveManager.is_stage_unlocked(stage_id):
		return false
	selected_stage_id = stage_id
	return true


func begin_boss_test(boss_scene: PackedScene, stage_id := "stage_1") -> void:
	pending_boss_test = boss_scene
	selected_stage_id = stage_id


func consume_boss_test() -> PackedScene:
	var boss_scene := pending_boss_test
	pending_boss_test = null
	return boss_scene
