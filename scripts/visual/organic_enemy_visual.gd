class_name OrganicEnemyVisual
extends Node2D

## A shared, very low-cost alien-machinery accent for every enemy and boss.
## It keeps all collision and combat geometry in the original scene nodes.
var _time := 0.0
var _hit_pulse := 0.0
var _eye: Polygon2D


func _ready() -> void:
	z_index = 1
	_eye = Polygon2D.new()
	_eye.polygon = PackedVector2Array([Vector2(0, -8), Vector2(6, 0), Vector2(0, 8), Vector2(-6, 0)])
	_eye.color = Color(0.15, 1.0, 0.82, 0.9)
	_eye.position = Vector2(0, -3)
	add_child(_eye)
	scale = Vector2.ONE * 0.72
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _process(delta: float) -> void:
	_time += delta
	_hit_pulse = maxf(0.0, _hit_pulse - delta * 4.5)
	if _eye != null:
		var pulse := 1.0 + sin(_time * 4.0) * 0.14 + _hit_pulse * 0.35
		_eye.scale = Vector2.ONE * pulse
		_eye.color = Color(0.95, 0.38, 0.18, 1.0) if _hit_pulse > 0.0 else Color(0.16, 0.95, 0.78, 0.88)
	queue_redraw()


func pulse_on_hit(reflected: bool) -> void:
	_hit_pulse = 1.0
	if reflected and _eye != null:
		_eye.color = Color(0.35, 1.0, 1.0, 1.0)


func _draw() -> void:
	# Three subtle organic cables/tentacles; curves are redrawn rather than spawned.
	for index in 3:
		var side := -1.0 if index == 0 else 1.0 if index == 1 else 0.0
		var sway := sin(_time * (2.0 + index * 0.3) + index) * 5.0
		var points := PackedVector2Array([
			Vector2(side * 8.0, 8.0), Vector2(side * 16.0 + sway, 15.0), Vector2(side * 11.0 - sway, 25.0), Vector2(side * 19.0 + sway, 31.0)
		])
		draw_polyline(points, Color(0.08, 0.45, 0.42, 0.72), 2.0, true)
