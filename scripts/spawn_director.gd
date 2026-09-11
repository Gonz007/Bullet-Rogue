class_name SpawnDirector
extends Node

@export var waves: Array[WaveData] = []
@export var max_active_enemies := 7
@export_range(0.0, 0.5, 0.01) var health_growth_per_stage := 0.12
@export_range(0, 5) var active_enemy_growth_per_stage := 1

var _base_max_active_enemies := 7
var _stage_difficulty := 1

var _wave_index := 0
var _spawned := 0
var _timer := 0.8
var _resting := false
var _active := true
var _random := RandomNumberGenerator.new()

func _ready() -> void:
	_random.randomize()
	_base_max_active_enemies = max_active_enemies

func set_active(value: bool) -> void:
	_active = value


func set_stage_difficulty(difficulty: int) -> void:
	_stage_difficulty = max(1, difficulty)
	max_active_enemies = _base_max_active_enemies + active_enemy_growth_per_stage * (_stage_difficulty - 1)

func _process(delta: float) -> void:
	if not _active or waves.is_empty():
		return
	_timer -= delta
	if _timer > 0.0:
		return
	if _resting:
		_resting = false
		_advance_wave()
		return
	var wave := waves[_wave_index]
	if _spawned < wave.spawn_count and get_tree().get_nodes_in_group("enemies").size() < max_active_enemies:
		_spawned += _spawn_from_wave(wave)
		_timer = wave.spawn_interval
	elif _spawned >= wave.spawn_count:
		_resting = true
		_timer = wave.rest_after

func _advance_wave() -> void:
	_wave_index = (_wave_index + 1) % waves.size()
	_spawned = 0
	_timer = 0.5

func _spawn_from_wave(wave: WaveData) -> int:
	if wave.enemy_scenes.is_empty():
		return 1
	if wave.formation != WaveData.Formation.NONE and _spawned == 0:
		_spawn_formation(wave)
		return wave.spawn_count
	var scene := wave.enemy_scenes[_random.randi_range(0, wave.enemy_scenes.size() - 1)]
	var enemy := scene.instantiate() as Enemy
	if enemy == null:
		return 1
	enemy.global_position = enemy.get_spawn_position(_random)
	if _random.randf() < wave.elite_chance:
		enemy.apply_elite()
	_apply_stage_scaling(enemy)
	_add_enemy(enemy)
	return 1


func _spawn_formation(wave: WaveData) -> void:
	var scene := wave.enemy_scenes[_random.randi_range(0, wave.enemy_scenes.size() - 1)]
	for index in wave.formation_size:
		if get_tree().get_nodes_in_group("enemies").size() >= max_active_enemies:
			break
		var enemy := scene.instantiate() as Enemy
		if enemy == null:
			continue
		var offset := _formation_offset(wave.formation, index, wave.formation_size)
		enemy.global_position = Vector2(240.0, -50.0) + offset
		if _random.randf() < wave.elite_chance:
			enemy.apply_elite()
		_apply_stage_scaling(enemy)
		_add_enemy(enemy)


func _formation_offset(formation: WaveData.Formation, index: int, count: int) -> Vector2:
	var centered := float(index) - float(count - 1) * 0.5
	match formation:
		WaveData.Formation.V:
			return Vector2(centered * 42.0, absf(centered) * 28.0)
		WaveData.Formation.DIAGONAL:
			return Vector2(centered * 48.0, centered * 22.0)
		WaveData.Formation.SERPENT:
			return Vector2(centered * 45.0, sin(index * 1.5) * 28.0)
		WaveData.Formation.CIRCLE:
			return Vector2(90.0, 0.0).rotated(TAU * float(index) / count)
	return Vector2.ZERO


func _add_enemy(enemy: Enemy) -> void:
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)


func _apply_stage_scaling(enemy: Enemy) -> void:
	if _stage_difficulty <= 1:
		return
	enemy.max_health = ceili(enemy.max_health * (1.0 + health_growth_per_stage * (_stage_difficulty - 1)))
	enemy.experience_value += _stage_difficulty - 1


func _on_enemy_died(enemy: Enemy, _damage_info: DamageInfo) -> void:
	var progress := get_parent().get_node_or_null("RunProgress") as RunProgress
	if progress != null:
		progress.gain_experience(enemy.experience_value)
