class_name StageData
extends Resource

@export var id := "stage_1"
@export var display_name := "Stage 1: First Contact"
@export_multiline var description := ""
@export var target_duration := 180.0
@export var difficulty := 1
@export var waves: Array[WaveData] = []
@export var enemy_pool: Array[PackedScene] = []
@export var background_color := Color(0.025, 0.04, 0.1)
@export var boss_scene: PackedScene
@export var unlock_requirement := ""
