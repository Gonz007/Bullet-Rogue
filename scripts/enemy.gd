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
var is_elite := false


func _ready() -> void:
	health = max_health
	add_to_group("enemies")
	body_entered.connect(_on_body_entered)
	var visual := OrganicEnemyVisual.new()
	visual.name = "OrganicMachineAccent"
	add_child(visual)


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
		AudioManager.play_sfx("enemy_kill")
		get_tree().call_group("screen_shake", "shake", 2.0, 0.07)
		_play_death_visual()


func leave_arena_if_needed() -> void:
	if global_position.y > 910.0:
		queue_free()


func get_spawn_position(random: RandomNumberGenerator) -> Vector2:
	return Vector2(random.randf_range(50.0, 430.0), -45.0)


func apply_elite() -> void:
	if is_elite:
		return
	is_elite = true
	max_health = ceili(max_health * 1.5)
	experience_value *= 2
	coin_drop_chance = minf(1.0, coin_drop_chance + 0.2)
	contact_damage += 1
	scale *= 1.12
	modulate = Color(1.0, 0.72, 0.18)
	if self is Chaser:
		var chaser := self as Chaser
		chaser.horizontal_speed *= 1.28
		chaser.descent_speed *= 1.16
	if self is Shooter:
		(self as Shooter).fire_interval *= 0.72
	if self is BurstEnemy:
		var burst := self as BurstEnemy
		burst.burst_count += 2
		burst.burst_interval *= 0.8


func _flash_hit(reflected: bool) -> void:
	var visual := get_node_or_null("OrganicMachineAccent") as OrganicEnemyVisual
	if visual != null:
		visual.pulse_on_hit(reflected)
	modulate = Color(0.4, 0.95, 1.0) if reflected else Color.WHITE
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)


func _play_death_visual() -> void:
	# Mark the dead target inert immediately, then allow a tiny visual breakdown.
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", scale * 1.22, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.14)
	tween.chain().tween_callback(queue_free)


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
