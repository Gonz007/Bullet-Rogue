class_name GeometryBoss
extends Boss

@export var projectile_scene: PackedScene
@export var attack_interval := 1.25

var _attack_elapsed := 0.7
var _attack_index := 0
var _telegraph := 0.0


func _ready() -> void:
	super()
	boss_id = "boss_1"
	boss_display_name = "ORBITAL GEOMETRY"
	queue_redraw()


func _process(delta: float) -> void:
	_telegraph = maxf(0.0, _telegraph - delta)
	_attack_elapsed -= delta
	if _attack_elapsed <= 0.0:
		_attack_elapsed = attack_interval
		_attack()
	queue_redraw()


func _attack() -> void:
	_telegraph = 0.22
	var player := get_tree().get_first_node_in_group("player") as Player
	var target_position := player.global_position if player != null else Vector2(240, 700)
	match current_phase:
		1:
			if _attack_index % 3 == 0:
				BulletPatterns.circle(self, projectile_scene, 10, 155.0, 1, _attack_index * 0.12)
			elif _attack_index % 3 == 1:
				BulletPatterns.fan(self, projectile_scene, 5, 0.72, target_position, 230.0)
			else:
				BulletPatterns.spiral(self, projectile_scene, 5, 175.0, _attack_index * 0.35)
		2:
			if _attack_index % 2 == 0:
				BulletPatterns.double_spiral(self, projectile_scene, 5, 185.0, _attack_index * 0.28)
			else:
				BulletPatterns.fan(self, projectile_scene, 7, 1.05, target_position, 245.0)
		3:
			BulletPatterns.circle(self, projectile_scene, 12, 175.0, 1, _attack_index * 0.18)
			BulletPatterns.fan(self, projectile_scene, 5, 0.8, target_position, 270.0)
	_attack_index += 1


func _draw() -> void:
	var flash := 1.0 if _telegraph > 0.0 else 0.0
	draw_circle(Vector2.ZERO, 38.0 + flash * 8.0, Color(0.12 + flash * 0.35, 0.72, 1.0, 0.2))
	draw_arc(Vector2.ZERO, 38.0, 0.0, TAU, 32, Color(0.28, 0.92, 1.0), 2.0 + flash * 2.0)
	draw_arc(Vector2.ZERO, 24.0, -_attack_index * 0.18, TAU - _attack_index * 0.18, 24, Color(1.0, 0.45, 0.25), 2.0)
