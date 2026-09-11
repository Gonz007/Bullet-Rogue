extends Node

signal sound_requested(event_name: String)

@export var sfx_streams: Dictionary = {}
@export var music_streams: Dictionary = {}

var _sfx_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = &"SFX"
	add_child(_sfx_player)
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	add_child(_music_player)


func play_sfx(event_name: String) -> void:
	sound_requested.emit(event_name)
	var stream := sfx_streams.get(event_name) as AudioStream
	if stream != null:
		_sfx_player.stream = stream
		_sfx_player.play()


func play_music(track_name: String) -> void:
	var stream := music_streams.get(track_name) as AudioStream
	if stream == null or _music_player.stream == stream:
		return
	_music_player.stream = stream
	_music_player.play()


func stop_music() -> void:
	_music_player.stop()
