class_name StrikeDrone
extends Node2D

var target_position := Vector2.ZERO
var fire_interval := 0.32
var projectile_damage := 1
var projectile_speed := 720.0

var _elapsed := 0.0
var _card_manager: CardManager


func configure(card_manager: CardManager, initial_position: Vector2) -> void:
	_card_manager = card_manager
	global_position = initial_position
	queue_redraw()


func _process(delta: float) -> void:
	global_position = global_position.lerp(target_position, minf(1.0, delta * 9.0))
	_elapsed += delta
	if _elapsed >= fire_interval and _card_manager != null:
		_elapsed -= fire_interval
		_card_manager.spawn_player_projectiles(global_position, [Vector2.UP], projectile_damage, projectile_speed, {"synergy": "strike_drones", "drone_shot": true})


func _draw() -> void:
	var hull := PackedVector2Array([Vector2(0, -12), Vector2(9, 8), Vector2(0, 5), Vector2(-9, 8)])
	draw_colored_polygon(hull, Color(0.22, 0.92, 1.0, 0.95))
	draw_circle(Vector2(0, 1), 3.0, Color(0.9, 0.98, 1.0))
	draw_line(Vector2(-5, 8), Vector2(-5, 14), Color(0.28, 0.65, 1.0, 0.7), 2.0)
	draw_line(Vector2(5, 8), Vector2(5, 14), Color(0.28, 0.65, 1.0, 0.7), 2.0)
