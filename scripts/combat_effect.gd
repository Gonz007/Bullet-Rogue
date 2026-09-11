class_name CombatEffect
extends Node2D

var color := Color.WHITE
var final_radius := 24.0
var lifetime := 0.18
var elapsed := 0.0


static func spawn(world: Node, effect_position: Vector2, effect_color: Color, radius := 24.0) -> void:
	var effect := CombatEffect.new()
	effect.global_position = effect_position
	effect.color = effect_color
	effect.final_radius = radius
	world.add_child(effect)


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()
	if elapsed >= lifetime:
		queue_free()


func _draw() -> void:
	var progress := elapsed / lifetime
	var current_color := color
	current_color.a *= 1.0 - progress
	draw_circle(Vector2.ZERO, lerpf(4.0, final_radius, progress), current_color, false, 2.0)
