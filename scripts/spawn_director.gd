class_name SpawnDirector
extends Node

@export var waves: Array[WaveData] = []
@export var max_active_enemies := 7

var _wave_index := 0
var _spawned := 0
var _timer := 0.8
var _resting := false
var _active := true
var _random := RandomNumberGenerator.new()

func _ready() -> void:
	_random.randomize()

func set_active(value: bool) -> void:
	_active = value

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
		_spawn_from_wave(wave)
		_spawned += 1
		_timer = wave.spawn_interval
	elif _spawned >= wave.spawn_count:
		_resting = true
		_timer = wave.rest_after

func _advance_wave() -> void:
	_wave_index = (_wave_index + 1) % waves.size()
	_spawned = 0
	_timer = 0.5

func _spawn_from_wave(wave: WaveData) -> void:
	if wave.enemy_scenes.is_empty():
		return
	var scene := wave.enemy_scenes[_random.randi_range(0, wave.enemy_scenes.size() - 1)]
	var enemy := scene.instantiate() as Enemy
	if enemy == null:
		return
	enemy.global_position = enemy.get_spawn_position(_random)
	if _random.randf() < wave.elite_chance:
		enemy.max_health = ceili(enemy.max_health * 1.5)
		enemy.experience_value *= 2
		enemy.coin_drop_chance = minf(1.0, enemy.coin_drop_chance + 0.2)
		enemy.modulate = Color(1.0, 0.75, 0.22)
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)


func _on_enemy_died(enemy: Enemy, _damage_info: DamageInfo) -> void:
	var progress := get_parent().get_node_or_null("RunProgress") as RunProgress
	if progress != null:
		progress.gain_experience(enemy.experience_value)
