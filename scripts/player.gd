class_name Player
extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)
signal parry_state_changed(is_active: bool)
signal projectile_parried(projectile: Projectile)
signal died

@export var move_speed := 380.0
@export var max_health := 3
@export_category("Parry")
@export_range(0.08, 0.5, 0.01, "suffix:s") var double_tap_window := 0.22
@export_range(0.05, 0.4, 0.01, "suffix:s") var parry_duration := 0.16
@export_range(40.0, 220.0, 1.0, "suffix:px") var dash_distance := 105.0
@export_range(300.0, 1800.0, 10.0, "suffix:px/s") var dash_speed := 1050.0
@export_range(300.0, 2400.0, 10.0, "suffix:px/s") var reflected_projectile_speed := 1100.0

var health := max_health
var is_invulnerable := false
var is_dead := false
var _is_parrying := false
var _dash_direction := 0.0
var _dash_distance_remaining := 0.0
var _parry_time_remaining := 0.0
var _last_tap_time := {"move_left": -1.0, "move_right": -1.0}


func _ready() -> void:
	add_to_group("player")
	$Weapon.configure(self, $Muzzle)
	$ParryArea.area_entered.connect(_on_parry_area_entered)


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if _is_parrying:
		_update_parry(delta)
		return
	var direction := Input.get_axis("move_left", "move_right")
	velocity = Vector2(direction * move_speed, 0.0)
	move_and_slide()
	_clamp_to_screen()


func _unhandled_input(event: InputEvent) -> void:
	if is_dead or _is_parrying:
		return
	for action in ["move_left", "move_right"]:
		if event.is_action_pressed(action) and not event.is_echo():
			_try_start_parry(action)
			get_viewport().set_input_as_handled()
			return


func _try_start_parry(action: String) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	var previous_tap: float = _last_tap_time[action]
	_last_tap_time[action] = now
	if now - previous_tap <= double_tap_window:
		_last_tap_time[action] = -1.0
		_start_parry(-1.0 if action == "move_left" else 1.0)


func _start_parry(direction: float) -> void:
	_is_parrying = true
	is_invulnerable = true
	_dash_direction = direction
	_dash_distance_remaining = dash_distance
	_parry_time_remaining = parry_duration
	$ParryArea.monitoring = true
	parry_state_changed.emit(true)
	queue_redraw()


func _update_parry(delta: float) -> void:
	if _dash_distance_remaining > 0.0:
		var movement := minf(dash_speed * delta, _dash_distance_remaining)
		position.x += _dash_direction * movement
		_dash_distance_remaining -= movement
		_clamp_to_screen()
	_parry_time_remaining -= delta
	if _parry_time_remaining <= 0.0:
		_finish_parry()


func _finish_parry() -> void:
	_is_parrying = false
	is_invulnerable = false
	velocity = Vector2.ZERO
	$ParryArea.monitoring = false
	parry_state_changed.emit(false)
	queue_redraw()


func _clamp_to_screen() -> void:
	position.x = clampf(position.x, 24.0, 456.0)


func take_damage(amount: int) -> void:
	if is_invulnerable or is_dead:
		return
	health = max(health - amount, 0)
	health_changed.emit(health, max_health)
	if health == 0:
		is_dead = true
		$Weapon.set_active(false)
		modulate = Color(0.4, 0.4, 0.5)
		died.emit()


func _on_parry_area_entered(area: Area2D) -> void:
	if not _is_parrying or not area.has_method("reflect"):
		return
	area.reflect(Vector2.UP, reflected_projectile_speed, self)
	if area is Projectile and area.team == Projectile.Team.PLAYER:
		projectile_parried.emit(area)


func _draw() -> void:
	if _is_parrying:
		draw_arc(Vector2.ZERO, 34.0, 0.0, TAU, 24, Color(0.35, 0.9, 1.0, 0.9), 2.0)
