class_name ChaosBoss
extends Boss

@export var projectile_scene: PackedScene
@export var attack_interval := 1.2

var _elapsed := 0.6
var _attack_index := 0
var _telegraph := 0.0


func _ready() -> void:
	super()
	boss_id = "boss_3"
	boss_display_name = "CHAOS ARRAY"
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed -= delta
	_telegraph = maxf(0.0, _telegraph - delta)
	if _elapsed <= 0.0:
		_elapsed = attack_interval
		_attack()
	queue_redraw()


func _attack() -> void:
	_telegraph = 0.2
	var angle := _attack_index * 0.26
	match current_phase:
		1:
			if _attack_index % 2 == 0:
				BulletPatterns.star(self, projectile_scene, 5, 180.0, angle)
			else:
				BulletPatterns.flower(self, projectile_scene, 5, 175.0, angle)
		2:
			if _attack_index % 2 == 0:
				BulletPatterns.double_spiral(self, projectile_scene, 6, 190.0, angle)
			else:
				BulletPatterns.rotating_ring(self, projectile_scene, 12, 165.0, angle)
		3:
			BulletPatterns.star(self, projectile_scene, 6, 200.0, angle)
			BulletPatterns.flower(self, projectile_scene, 4, 185.0, -angle)
			BulletPatterns.double_spiral(self, projectile_scene, 4, 220.0, angle)
	_attack_index += 1


func _draw() -> void:
	var pulse := 1.0 if _telegraph > 0.0 else 0.0
	for index in 3:
		draw_arc(Vector2.ZERO, 18.0 + index * 12.0 + pulse * 5.0, -_attack_index * 0.12 * (index + 1), TAU - _attack_index * 0.12 * (index + 1), 24, Color(0.8, 0.28 + index * 0.18, 1.0), 2.0)
	draw_circle(Vector2.ZERO, 12.0 + pulse * 3.0, Color(1.0, 0.86, 0.35))
