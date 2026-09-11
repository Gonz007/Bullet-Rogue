class_name WaveData
extends Resource

enum Formation { NONE, V, DIAGONAL, SERPENT, CIRCLE }

@export var display_name := "Wave"
@export var enemy_scenes: Array[PackedScene] = []
@export var spawn_count := 4
@export var spawn_interval := 1.2
@export var rest_after := 2.0
@export var elite_chance := 0.0
@export var formation := Formation.NONE
@export_range(3, 10) var formation_size := 5
