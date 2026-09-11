class_name BackdropAtmosphere
extends Node2D

## Lightweight moving haze drawn in code.  It sits above the painted sky but below
## gameplay, so it gives depth without a second large texture on mobile devices.
@export var drift_speed := 7.0

var _drift := 0.0


func _process(delta: float) -> void:
	_drift = fmod(_drift + drift_speed * delta, 260.0)
	queue_redraw()


func _draw() -> void:
	for layer in 4:
		var y := 140.0 + layer * 210.0 + _drift
		if y > 930.0:
			y -= 840.0
		var tint := Color(0.08, 0.2, 0.24, 0.08 + layer * 0.012)
		for puff in 6:
			var x := 35.0 + puff * 95.0 + sin(_drift * 0.018 + layer + puff) * 18.0
			var radius := 38.0 + float((puff + layer) % 3) * 14.0
			draw_circle(Vector2(x, y + sin(puff * 1.6) * 11.0), radius, tint)
