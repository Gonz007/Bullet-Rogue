class_name CoinPickup
extends Area2D

@export var amount := 1
@export var magnet_radius := 95.0
@export var magnet_speed := 360.0

var _pulse_time := 0.0
var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_pulse_time += delta
	rotation += delta * 2.5
	var pulse := 1.0 + sin(_pulse_time * 5.0) * 0.12
	$Visual.scale = Vector2.ONE * pulse
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null and global_position.distance_to(player.global_position) <= magnet_radius:
		global_position = global_position.move_toward(player.global_position, magnet_speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body is Player:
		return
	_collected = true
	SaveManager.add_coins(amount)
	CombatEffect.spawn(get_tree().current_scene, global_position, Color(1.0, 0.78, 0.2), 22.0)
	queue_free()
