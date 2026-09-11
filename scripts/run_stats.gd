class_name RunStats
extends Node

var started_at := 0
var kills := 0
var boss_id := ""
var coins_collected := 0


func _ready() -> void:
	started_at = Time.get_ticks_msec()
	add_to_group("run_stats")


func register_kill(_enemy: Enemy) -> void:
	kills += 1


func register_coins(amount: int) -> void:
	coins_collected += max(amount, 0)


func elapsed_seconds() -> int:
	return int((Time.get_ticks_msec() - started_at) / 1000)
