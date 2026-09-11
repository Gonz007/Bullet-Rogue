class_name CorridorBoss
extends Boss

@export var projectile_scene: PackedScene
@export var attack_interval := 1.45

var _elapsed := 0.8
var _attack_index := 0
var _telegraph := 0.0


func _ready() -> void:
	super()
	boss_id = "boss_2"
	boss_display_name = "IRON CORRIDOR"
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed -= delta
	_telegraph = maxf(0.0, _telegraph - delta)
	if _elapsed <= 0.0:
		_elapsed = attack_interval
		_attack()
	queue_redraw()


func _attack() -> void:
	_telegraph = 0.25
	var player := get_tree().get_first_node_in_group("player") as Player
	var target := player.global_position if player != null else Vector2(240, 700)
	match current_phase:
		1:
			if _attack_index % 2 == 0:
				BulletPatterns.wall(self, projectile_scene, 9, 52.0, 165.0, int(_attack_index / 2) % 9, true)
			else:
				BulletPatterns.line(self, projectile_scene, 5, 26.0, (target - global_position).normalized(), 245.0)
		2:
			if _attack_index % 2 == 0:
				BulletPatterns.tunnel(self, projectile_scene, 185.0, (_attack_index * 2) % 9, true)
			else:
				BulletPatterns.cross(self, projectile_scene, 185.0)
				BulletPatterns.fan(self, projectile_scene, 3, 0.42, target, 260.0)
		3:
			BulletPatterns.wall(self, projectile_scene, 10, 48.0, 210.0, (_attack_index * 3) % 10)
			BulletPatterns.fan(self, projectile_scene, 5, 0.68, target, 285.0)
	_attack_index += 1


func _draw() -> void:
	var pulse := 1.0 if _telegraph > 0.0 else 0.0
	draw_rect(Rect2(-45, -32, 90, 64), Color(0.75, 0.27 + pulse * 0.3, 0.2, 0.24), true)
	draw_rect(Rect2(-45, -32, 90, 64), Color(1.0, 0.4, 0.2), false, 3.0 + pulse * 2.0)
	draw_line(Vector2(-30, 0), Vector2(30, 0), Color(1, 0.8, 0.35), 3.0)
