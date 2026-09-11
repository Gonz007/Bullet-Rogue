class_name Weapon
extends Node

signal projectile_fired(projectile: Projectile)

@export var projectile_scene: PackedScene
@export_range(0.05, 1.0, 0.01, "suffix:s") var fire_interval := 0.18
@export var projectile_damage := 1
@export var projectile_speed := 720.0

var _source: Node2D
var _muzzle: Node2D
var _active := true
var _elapsed := 0.0
var _card_manager: CardManager


func configure(source: Node2D, muzzle: Node2D) -> void:
	_source = source
	_muzzle = muzzle


func set_active(value: bool) -> void:
	_active = value


func set_card_manager(card_manager: CardManager) -> void:
	_card_manager = card_manager


func _process(delta: float) -> void:
	if not _active or _source == null or _muzzle == null or projectile_scene == null:
		return
	_elapsed += delta
	var current_interval := _card_manager.get_fire_interval(fire_interval) if _card_manager != null else fire_interval
	if _elapsed >= current_interval:
		_elapsed -= current_interval
		fire(Vector2.UP)


func fire(shot_direction: Vector2) -> void:
	var context := _card_manager.build_shot_context(shot_direction, projectile_damage, projectile_speed) if _card_manager != null else {"directions": [shot_direction], "damage": projectile_damage, "speed": projectile_speed, "tags": [], "metadata": {}}
	for direction in context["directions"]:
		var projectile := projectile_scene.instantiate() as Projectile
		projectile.global_position = _muzzle.global_position
		get_tree().current_scene.add_child(projectile)
		projectile.configure(Projectile.Team.PLAYER, direction, context["damage"], context["speed"], _source)
		projectile.metadata = context["metadata"].duplicate()
		projectile.damage_info.tags.append_array(context["tags"])
		if _card_manager != null:
			_card_manager.register_projectile(projectile)
		projectile_fired.emit(projectile)
	if _source != null and _source.has_method("play_shot_feedback"):
		_source.play_shot_feedback()
	AudioManager.play_sfx("player_shot")
