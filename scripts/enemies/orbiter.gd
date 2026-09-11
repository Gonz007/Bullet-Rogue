class_name Orbiter
extends Enemy

@export var projectile_scene: PackedScene
@export var orbit_radius := 90.0
@export var orbit_speed := 1.15
@export var fire_interval := 2.2
@export var projectile_speed := 150.0
var _center := Vector2(240, 190)
var _angle := 0.0
var _fire_time := 1.0

func _ready() -> void:
	_center.x = global_position.x
	super()

func _physics_process(delta: float) -> void:
	_angle += orbit_speed * delta
	global_position = _center + Vector2(cos(_angle), sin(_angle)) * orbit_radius
	_fire_time -= delta
	if _fire_time <= 0.0:
		_fire_time = fire_interval
		_fire_ring()

func _fire_ring() -> void:
	if projectile_scene == null:
		return
	for index in 6:
		var projectile := projectile_scene.instantiate() as Projectile
		projectile.global_position = global_position
		get_tree().current_scene.add_child(projectile)
		projectile.configure(Projectile.Team.ENEMY, Vector2.DOWN.rotated(TAU * float(index) / 6.0), 1, projectile_speed, self)
