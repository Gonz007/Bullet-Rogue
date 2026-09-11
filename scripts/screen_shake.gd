class_name ScreenShake
extends Node

var _remaining := 0.0
var _strength := 0.0
var _random := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("screen_shake")
	_random.randomize()


func shake(strength := 4.0, duration := 0.12) -> void:
	if not SaveManager.is_screen_shake_enabled():
		return
	_strength = maxf(_strength, strength)
	_remaining = maxf(_remaining, duration)


func _process(delta: float) -> void:
	var root := get_parent() as Node2D
	if root == null:
		return
	_remaining -= delta
	if _remaining > 0.0:
		root.position = Vector2(_random.randf_range(-_strength, _strength), _random.randf_range(-_strength, _strength))
		_strength = move_toward(_strength, 0.0, delta * 24.0)
	else:
		root.position = Vector2.ZERO
