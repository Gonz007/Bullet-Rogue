class_name Boss
extends Enemy

signal health_updated(current: int, maximum: int)
signal phase_changed(phase: int, phase_count: int)
signal defeated(boss: Boss, damage_info: DamageInfo)

@export var boss_id := "boss_1"
@export var boss_display_name := "UNKNOWN BOSS"
@export_range(1, 5) var phase_count := 3

var current_phase := 1


func _ready() -> void:
	super()
	add_to_group("bosses")
	health_updated.emit(health, max_health)
	phase_changed.emit(current_phase, phase_count)


func take_damage(damage_info: DamageInfo) -> void:
	if _is_defeated:
		return
	health -= damage_info.amount
	_flash_hit(damage_info.metadata.get("reflected", false))
	var next_phase := clampi(phase_count - ceili(float(health) / float(max_health) * phase_count) + 1, 1, phase_count)
	if next_phase != current_phase and health > 0:
		current_phase = next_phase
		phase_changed.emit(current_phase, phase_count)
	health_updated.emit(maxi(health, 0), max_health)
	if health <= 0:
		_is_defeated = true
		get_tree().call_group("run_stats", "register_kill", self)
		defeated.emit(self, damage_info)
		died.emit(self, damage_info)
		CombatEffect.spawn(get_tree().current_scene, global_position, Color(0.4, 0.95, 1.0), 96.0)
		_play_death_visual()
