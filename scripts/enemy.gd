class_name Enemy
extends Area2D

signal died(enemy: Enemy, damage_info: DamageInfo)

@export var max_health := 3
@export var score_value := 1
@export var experience_value := 2
@export_category("Permanent Coin Drops")
@export_range(0.0, 1.0, 0.01) var coin_drop_chance := 0.05
@export var coin_drop_amount_min := 1
@export var coin_drop_amount_max := 1
@export var coin_pickup_scene: PackedScene
@export_category("Contact")
@export var contact_damage := 1
@export var destroys_on_contact := true

var health := 0
var _is_defeated := false


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)


func take_damage(damage_info: DamageInfo) -> void:
	if _is_defeated:
		return
	health -= damage_info.amount
	_flash_hit(damage_info.metadata.get("reflected", false))
	if health <= 0:
		_is_defeated = true
		get_tree().call_group("run_stats", "register_kill", self)
		_try_drop_coins()
		died.emit(self, damage_info)
		var color := Color(0.25, 0.95, 1.0) if damage_info.metadata.get("reflected", false) else Color(1.0, 0.55, 0.25)
		CombatEffect.spawn(get_tree().current_scene, global_position, color, 32.0)
		queue_free()


func leave_arena_if_needed() -> void:
	if global_position.y > 910.0:
		queue_free()


func get_spawn_position(random: RandomNumberGenerator) -> Vector2:
	return Vector2(random.randf_range(50.0, 430.0), -45.0)


func _flash_hit(reflected: bool) -> void:
	modulate = Color(0.4, 0.95, 1.0) if reflected else Color.WHITE
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _try_drop_coins() -> void:
	if coin_pickup_scene == null or randf() > coin_drop_chance:
		return
	var coin := coin_pickup_scene.instantiate() as CoinPickup
	coin.global_position = global_position
	coin.amount = randi_range(coin_drop_amount_min, max(coin_drop_amount_min, coin_drop_amount_max))
	get_tree().current_scene.call_deferred("add_child", coin)


func _on_body_entered(body: Node2D) -> void:
	if _is_defeated or not body is Player:
		return
	body.take_damage(contact_damage)
	if destroys_on_contact:
		queue_free()
