class_name EnemySpriteVisual
extends Node2D

## Visual adapter for the supplied sprite sheet.  It deliberately does not alter
## the host's collision shapes, movement state, damage or firing logic.
const CHASER_TEXTURE := preload("res://assets/sprites/enemies/chaser.png")
const SHOOTER_TEXTURE := preload("res://assets/sprites/enemies/shooter.png")
const BURST_TEXTURE := preload("res://assets/sprites/enemies/burst.png")
const RAMMER_TEXTURE := preload("res://assets/sprites/enemies/rammer.png")
const LARGE_TEXTURE := preload("res://assets/sprites/enemies/large.png")
const BOSS_TEXTURE := preload("res://assets/sprites/bosses/leviathan_boss.png")
const STANDARD_SPRITE_SIZE := 64.0
const BOSS_SPRITE_SIZE := 170.0


func _ready() -> void:
	var host := get_parent() as Enemy
	if host == null:
		return
	_hide_legacy_polygons(host)
	var sprite := Sprite2D.new()
	sprite.texture = _texture_for(host)
	# Crops have different source resolutions. Normalize them to a fixed on-screen
	# size so a tall source image cannot turn a regular enemy into a giant.
	var texture_size := sprite.texture.get_size()
	var largest_side := maxf(texture_size.x, texture_size.y)
	var target_size := BOSS_SPRITE_SIZE if host is Boss else STANDARD_SPRITE_SIZE
	sprite.scale = Vector2.ONE * target_size / largest_side
	sprite.z_index = 0
	add_child(sprite)


func _texture_for(host: Enemy) -> Texture2D:
	if host is Boss:
		return BOSS_TEXTURE
	if host.name.contains("Rammer"):
		return RAMMER_TEXTURE
	if host is BurstEnemy:
		return BURST_TEXTURE
	if host is Shooter:
		return SHOOTER_TEXTURE
	if host is Chaser:
		return CHASER_TEXTURE
	return LARGE_TEXTURE


func _hide_legacy_polygons(host: Enemy) -> void:
	for node_name in ["Body", "Visual", "Core", "Barrel"]:
		var legacy := host.get_node_or_null(node_name) as CanvasItem
		if legacy != null:
			legacy.visible = false
