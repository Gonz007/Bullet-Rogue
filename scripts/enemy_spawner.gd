class_name EnemySpawner
extends Node

@export var chaser_scene: PackedScene
@export var shooter_scene: PackedScene
@export var burst_scene: PackedScene
@export var turret_scene: PackedScene
@export var fast_chaser_scene: PackedScene
@export var heavy_chaser_scene: PackedScene
@export var zigzag_chaser_scene: PackedScene
@export var rammer_scene: PackedScene
@export var straight_shooter_scene: PackedScene
@export var spread_shooter_scene: PackedScene
@export var spawn_interval := 3.0
@export var max_active_enemies := 5

var _elapsed := 0.8
var _next_type := 0
var _random := RandomNumberGenerator.new()
var _active := true


func _ready() -> void:
	_random.randomize()


func set_active(value: bool) -> void:
	_active = value


func _process(delta: float) -> void:
	if not _active:
		return
	_elapsed -= delta
	if _elapsed <= 0.0:
		_elapsed = spawn_interval
		_spawn_next()


func _spawn_next() -> void:
	if get_tree().get_nodes_in_group("enemies").size() >= max_active_enemies:
		return
	var scenes := [chaser_scene, shooter_scene, burst_scene, turret_scene, fast_chaser_scene, heavy_chaser_scene, zigzag_chaser_scene, rammer_scene, straight_shooter_scene, spread_shooter_scene]
	var enemy_scene: PackedScene = scenes[_next_type]
	_next_type = (_next_type + 1) % scenes.size()
	if enemy_scene == null:
		return
	var enemy := enemy_scene.instantiate() as Enemy
	enemy.global_position = enemy.get_spawn_position(_random)
	enemy.died.connect(_on_enemy_died)
	get_parent().add_child(enemy)


func _on_enemy_died(enemy: Enemy, _damage_info: DamageInfo) -> void:
	var progress := get_parent().get_node_or_null("RunProgress") as RunProgress
	if progress != null:
		progress.gain_experience(enemy.experience_value)
