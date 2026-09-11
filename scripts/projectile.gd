class_name Projectile
extends Area2D

enum Team { PLAYER, ENEMY }

signal reflected(projectile: Projectile)
signal impact(projectile: Projectile, target: Node)

@export var speed := 720.0
@export var direction := Vector2.UP
@export var damage := 1
@export var projectile_type := "standard"
@export var can_be_reflected := true

var team := Team.PLAYER
var damage_info: DamageInfo
var metadata: Dictionary = {}
var pierce_remaining := 0
var bounces_remaining := 0

const MAX_ACTIVE_PROJECTILES := 360


func _ready() -> void:
	if get_tree().get_nodes_in_group("projectiles").size() >= MAX_ACTIVE_PROJECTILES:
		queue_free()
		return
	add_to_group("projectiles")
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	_create_damage_info()
	_apply_collision_profile()
	_update_visuals()


func configure(new_team: Team, new_direction: Vector2, new_damage: int, new_speed: float, source: Node) -> void:
	team = new_team
	direction = new_direction.normalized()
	damage = new_damage
	speed = new_speed
	_create_damage_info(source)
	_apply_collision_profile()
	_update_visuals()


func _process(delta: float) -> void:
	if metadata.get("rocket", false):
		var targets := get_tree().get_nodes_in_group("enemies")
		if not targets.is_empty():
			var target := targets[0] as Enemy
			if target != null:
				direction = direction.lerp((target.global_position - global_position).normalized(), minf(5.0 * delta, 1.0)).normalized()
	global_position += direction * speed * delta
	rotation = direction.angle() + PI / 2.0
	if team == Team.PLAYER and bounces_remaining > 0 and (global_position.x < 4.0 or global_position.x > 476.0):
		global_position.x = clampf(global_position.x, 4.0, 476.0)
		direction.x *= -1.0
		bounces_remaining -= 1
	if global_position.y < -50.0 or global_position.y > 904.0 or global_position.x < -50.0 or global_position.x > 530.0:
		queue_free()


func reflect(new_direction: Vector2, new_speed: float, new_owner: Node = null) -> void:
	if team != Team.ENEMY or not can_be_reflected:
		return
	team = Team.PLAYER
	direction = new_direction.normalized()
	speed = new_speed
	damage_info.team = Team.PLAYER
	damage_info.amount = max(1, damage_info.amount * 3)
	damage_info.tags.append("reflected")
	damage_info.metadata["original_source"] = damage_info.source
	damage_info.metadata["reflected"] = true
	damage_info.source = new_owner
	metadata["reflected"] = true
	_apply_collision_profile()
	_update_visuals()
	CombatEffect.spawn(get_tree().current_scene, global_position, Color(0.25, 0.95, 1.0), 20.0)
	get_tree().call_group("screen_shake", "shake", 3.5, 0.1)
	AudioManager.play_sfx("reflect")
	reflected.emit(self)


func _on_area_entered(area: Area2D) -> void:
	if team == Team.PLAYER and area is Enemy:
		area.take_damage(damage_info)
		impact.emit(self, area)
		if pierce_remaining > 0:
			pierce_remaining -= 1
		else:
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	if team == Team.ENEMY and body is Player:
		body.take_damage(damage_info.amount)
		CombatEffect.spawn(get_tree().current_scene, global_position, Color(1.0, 0.3, 0.25), 14.0)
		queue_free()


func _create_damage_info(source: Node = null) -> void:
	if damage_info == null:
		damage_info = DamageInfo.new()
	damage_info.amount = damage
	damage_info.team = team
	damage_info.source = source


func _apply_collision_profile() -> void:
	if team == Team.PLAYER:
		collision_layer = 2
		collision_mask = 4
	else:
		collision_layer = 8
		collision_mask = 1


func _update_visuals() -> void:
	$Visual.color = Color(0.35, 0.95, 1.0) if team == Team.PLAYER and metadata.get("reflected", false) else (Color(1.0, 0.9, 0.25) if team == Team.PLAYER else Color(1.0, 0.3, 0.35))
