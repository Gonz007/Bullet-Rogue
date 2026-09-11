class_name DroneFormation
extends Node2D

@export var horizontal_offset := 72.0
@export var vertical_offset := 12.0

var _player: Player
var _card_manager: CardManager
var _drones: Array[StrikeDrone] = []


func configure(player: Player, card_manager: CardManager) -> void:
	_player = player
	_card_manager = card_manager
	SynergyManager.synergies_changed.connect(_on_synergies_changed)
	_refresh()


func _process(_delta: float) -> void:
	if _player == null:
		return
	for index in _drones.size():
		var side := -1.0 if index == 0 else 1.0
		_drones[index].target_position = _player.global_position + Vector2(horizontal_offset * side, vertical_offset)


func _on_synergies_changed(_active_synergies: Array[SynergyData]) -> void:
	_refresh()


func _refresh() -> void:
	if SynergyManager.has_synergy("strike_drones"):
		if _drones.is_empty() and _player != null:
			for side in [-1.0, 1.0]:
				var drone := StrikeDrone.new()
				add_child(drone)
				drone.configure(_card_manager, _player.global_position + Vector2(horizontal_offset * side, vertical_offset))
				_drones.append(drone)
	elif not _drones.is_empty():
		for drone in _drones:
			drone.queue_free()
		_drones.clear()
