class_name CoinPickup
extends Area2D

@export var amount := 1
@export var magnet_radius := 280.0
@export var magnet_speed := 620.0
@export var fall_speed := 95.0

var _pulse_time := 0.0
var _collected := false
var _settle_y := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Coins should never remain stranded at the kill position above the player.
	_settle_y = minf(global_position.y + 120.0, 690.0)


func _process(delta: float) -> void:
	_pulse_time += delta
	rotation += delta * 2.5
	var pulse := 1.0 + sin(_pulse_time * 5.0) * 0.12
	$Visual.scale = Vector2.ONE * pulse
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return
	var distance := global_position.distance_to(player.global_position)
	if distance <= magnet_radius:
		# Accelerate naturally near the ship; this works for normal and big drops.
		var speed := magnet_speed * (1.0 + (1.0 - distance / magnet_radius) * 1.8)
		global_position = global_position.move_toward(player.global_position, speed * delta)
	elif global_position.y < _settle_y:
		global_position.y = minf(_settle_y, global_position.y + fall_speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body is Player:
		return
	_collected = true
	SaveManager.add_coins(amount)
	get_tree().call_group("run_stats", "register_coins", amount)
	CombatEffect.spawn(get_tree().current_scene, global_position, Color(1.0, 0.78, 0.2), 22.0)
	AudioManager.play_sfx("coin_pickup")
	queue_free()
