class_name PlayerSteamVisual
extends Node2D

## Presentation-only rig.  Movement, collisions and the Weapon remain owned by
## Player; this node only reacts to the public feedback hooks below.
@onready var plane: Sprite2D = $PlaneSprite

var _idle_time := 0.0
var _recoil := 0.0
var _muzzle_flash := 0.0
var _parry_pulse := 0.0
var _hit_flash := 0.0


func _process(delta: float) -> void:
	_idle_time += delta
	_recoil = maxf(0.0, _recoil - delta * 30.0)
	_muzzle_flash = maxf(0.0, _muzzle_flash - delta * 10.0)
	_parry_pulse = maxf(0.0, _parry_pulse - delta * 3.8)
	_hit_flash = maxf(0.0, _hit_flash - delta * 5.5)

	var ship := get_parent() as Player
	var bank_target := 0.0
	if ship != null:
		bank_target = clampf(-ship.velocity.x / 1550.0, -0.22, 0.22)
	rotation = lerp_angle(rotation, bank_target, minf(delta * 9.0, 1.0))
	position = Vector2(sin(_idle_time * 2.2) * 1.4, sin(_idle_time * 3.1) * 1.7 + _recoil * 2.2)
	plane.modulate = Color(1.0, 0.52 + _hit_flash * 0.48, 0.52 + _hit_flash * 0.48, 1.0) if _hit_flash > 0.0 else Color.WHITE
	queue_redraw()


func play_shot_feedback() -> void:
	_recoil = 1.0
	_muzzle_flash = 1.0


func play_parry() -> void:
	_parry_pulse = 1.0


func play_hit() -> void:
	_hit_flash = 1.0


func _draw() -> void:
	# Animated turquoise propulsion below the brass aircraft.
	var flame := 17.0 + sin(_idle_time * 18.0) * 4.0
	draw_colored_polygon(PackedVector2Array([Vector2(-7, 23), Vector2(0, 23 + flame), Vector2(7, 23)]), Color(0.12, 0.95, 0.9, 0.42))
	draw_colored_polygon(PackedVector2Array([Vector2(-3, 23), Vector2(0, 19 + flame), Vector2(3, 23)]), Color(0.72, 1.0, 0.96, 0.92))
	# Brief brass/cyan cannon flare; weapon cadence and damage are unchanged.
	if _muzzle_flash > 0.0:
		var alpha := _muzzle_flash * 0.9
		draw_circle(Vector2(0, -31), 7.0 * _muzzle_flash + 2.0, Color(1.0, 0.55, 0.12, alpha))
	# Expanding parry wave, deliberately separate from the collision Area2D.
	if _parry_pulse > 0.0:
		var progress := 1.0 - _parry_pulse
		var radius := lerpf(24.0, 62.0, progress)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, Color(0.22, 1.0, 0.9, _parry_pulse * 0.9), 2.5)
		draw_circle(Vector2.ZERO, radius * 0.65, Color(0.1, 0.8, 0.75, _parry_pulse * 0.08))
