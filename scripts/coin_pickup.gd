class_name CoinPickup
extends Area2D

@export var amount := 1
@export var fall_speed := 180.0

var _pulse_time := 0.0
var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_pulse_time += delta
	rotation += delta * 2.5
	var pulse := 1.0 + sin(_pulse_time * 5.0) * 0.12
	$Visual.scale = Vector2.ONE * pulse
	# Drops travel only on Y.  The player must line up with them to collect them;
	# there is deliberately no hidden attraction or horizontal correction.
	global_position.y += fall_speed * delta
	if global_position.y > 900.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body is Player:
		return
	_collected = true
	SaveManager.add_coins(amount)
	get_tree().call_group("run_stats", "register_coins", amount)
	CombatEffect.spawn(get_tree().current_scene, global_position, Color(1.0, 0.78, 0.2), 22.0)
	AudioManager.play_sfx("coin_pickup")
	queue_free()
