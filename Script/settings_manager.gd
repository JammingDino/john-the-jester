extends Node

const SAVE_PATH = "user://settings.cfg"

var sfx_volume: int = 100
var music_volume: int = 100
var muted: bool = false
var fullscreen: bool = false

func _ready() -> void:
	load_settings()
	apply_settings()

func save_settings() -> void:
	var config = ConfigFile.new()
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "muted", muted)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		sfx_volume = config.get_value("audio", "sfx_volume", 100)
		music_volume = config.get_value("audio", "music_volume", 100)
		muted = config.get_value("audio", "muted", false)
		fullscreen = config.get_value("display", "fullscreen", false)

func apply_settings() -> void:
	_ensure_bus("SFX")
	_ensure_bus("Music")

	var sfx_idx = AudioServer.get_bus_index("SFX")
	var music_idx = AudioServer.get_bus_index("Music")

	AudioServer.set_bus_volume_db(sfx_idx, _volume_to_db(sfx_volume))
	AudioServer.set_bus_mute(sfx_idx, muted)

	AudioServer.set_bus_volume_db(music_idx, _volume_to_db(music_volume))
	AudioServer.set_bus_mute(music_idx, muted)

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx = AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _volume_to_db(volume: int) -> float:
	if volume <= 0:
		return -80.0
	return linear_to_db(volume / 100.0)
