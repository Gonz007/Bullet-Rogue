class_name RunProgress
extends Node

signal experience_changed(current_experience: int, required_experience: int)
signal level_changed(level: int)

@export var starting_experience_required := 10
@export_range(1.1, 2.0, 0.05) var requirement_growth := 1.35

var level := 1
var experience := 0
var experience_required := 0


func _ready() -> void:
	experience_required = starting_experience_required
	experience_changed.emit(experience, experience_required)
	level_changed.emit(level)


func gain_experience(amount: int) -> void:
	if amount <= 0:
		return
	experience += amount
	while experience >= experience_required:
		experience -= experience_required
		level += 1
		experience_required = ceili(experience_required * requirement_growth)
		level_changed.emit(level)
	experience_changed.emit(experience, experience_required)
