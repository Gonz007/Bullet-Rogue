class_name BulletPatterns
extends RefCounted

static func circle(source: Node2D, projectile_scene: PackedScene, count: int, speed: float, damage: int = 1, rotation_offset: float = 0.0, reflectable: bool = true) -> void:
	for index in count:
		_spawn(source, projectile_scene, Vector2.UP.rotated(rotation_offset + TAU * float(index) / count), speed, damage, reflectable)


static func arc(source: Node2D, projectile_scene: PackedScene, count: int, arc_width: float, direction: Vector2, speed: float, damage: int = 1) -> void:
	for index in count:
		var ratio := 0.5 if count == 1 else float(index) / float(count - 1)
		_spawn(source, projectile_scene, direction.rotated(lerpf(-arc_width * 0.5, arc_width * 0.5, ratio)), speed, damage)


static func fan(source: Node2D, projectile_scene: PackedScene, count: int, arc_width: float, target_position: Vector2, speed: float, damage: int = 1) -> void:
	arc(source, projectile_scene, count, arc_width, (target_position - source.global_position).normalized(), speed, damage)


static func spiral(source: Node2D, projectile_scene: PackedScene, count: int, speed: float, angle: float, damage: int = 1) -> void:
	for index in count:
		_spawn(source, projectile_scene, Vector2.UP.rotated(angle + TAU * float(index) / count), speed, damage)


static func double_spiral(source: Node2D, projectile_scene: PackedScene, count: int, speed: float, angle: float, damage: int = 1) -> void:
	spiral(source, projectile_scene, count, speed, angle, damage)
	spiral(source, projectile_scene, count, speed, angle + PI, damage)


static func wave(source: Node2D, projectile_scene: PackedScene, count: int, spacing: float, speed: float, damage: int = 1) -> void:
	for index in count:
		var offset := (float(index) - float(count - 1) * 0.5) * spacing
		_spawn(source, projectile_scene, Vector2.DOWN, speed, damage, true, source.global_position + Vector2(offset, 0.0))


static func line(source: Node2D, projectile_scene: PackedScene, count: int, spacing: float, direction: Vector2, speed: float, damage: int = 1) -> void:
	var perpendicular := direction.rotated(PI * 0.5)
	for index in count:
		var offset := (float(index) - float(count - 1) * 0.5) * spacing
		_spawn(source, projectile_scene, direction, speed, damage, true, source.global_position + perpendicular * offset)


static func wall(source: Node2D, projectile_scene: PackedScene, count: int, spacing: float, speed: float, gap_index: int = -1, heavy: bool = false) -> void:
	for index in count:
		if index == gap_index:
			continue
		var offset := (float(index) - float(count - 1) * 0.5) * spacing
		_spawn(source, projectile_scene, Vector2.DOWN, speed, 1, not heavy, source.global_position + Vector2(offset, 0.0))


static func cross(source: Node2D, projectile_scene: PackedScene, speed: float, damage: int = 1) -> void:
	for direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		_spawn(source, projectile_scene, direction, speed, damage)


static func star(source: Node2D, projectile_scene: PackedScene, points: int, speed: float, rotation_offset: float = 0.0) -> void:
	for index in points * 2:
		var radius_speed := speed if index % 2 == 0 else speed * 0.7
		_spawn(source, projectile_scene, Vector2.UP.rotated(rotation_offset + TAU * float(index) / float(points * 2)), radius_speed)


static func flower(source: Node2D, projectile_scene: PackedScene, petals: int, speed: float, angle: float) -> void:
	for index in petals:
		arc(source, projectile_scene, 3, 0.32, Vector2.UP.rotated(angle + TAU * float(index) / petals), speed)


static func diamond(source: Node2D, projectile_scene: PackedScene, speed: float) -> void:
	for angle in [0.0, PI * 0.5, PI, PI * 1.5]:
		_spawn(source, projectile_scene, Vector2.UP.rotated(angle + PI * 0.25), speed, 1)


static func tunnel(source: Node2D, projectile_scene: PackedScene, speed: float, opening_side: int, heavy: bool = false) -> void:
	wall(source, projectile_scene, 9, 52.0, speed, clampi(opening_side, 0, 8), heavy)


static func rotating_ring(source: Node2D, projectile_scene: PackedScene, count: int, speed: float, angle: float) -> void:
	circle(source, projectile_scene, count, speed, 1, angle)


static func _spawn(source: Node2D, projectile_scene: PackedScene, direction: Vector2, speed: float, damage: int = 1, reflectable: bool = true, position_override: Vector2 = Vector2.INF) -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	projectile.global_position = source.global_position if position_override == Vector2.INF else position_override
	source.get_tree().current_scene.add_child(projectile)
	projectile.configure(Projectile.Team.ENEMY, direction, damage, speed, source)
	projectile.set_reflectable(reflectable)
	projectile.metadata["pattern_bullet"] = true
