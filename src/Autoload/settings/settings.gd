class_name SettingsSingleton extends Node

const SETTINGS_PATH := "user://settings.cfg"
const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"


func _ready() -> void:
	_ensure_audio_buses()
	load_and_apply()


func _ensure_audio_buses() -> void:
	if AudioServer.get_bus_index(MUSIC_BUS) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, MUSIC_BUS)
		AudioServer.set_bus_send(idx, "Master")
	if AudioServer.get_bus_index(SFX_BUS) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, SFX_BUS)
		AudioServer.set_bus_send(idx, "Master")


func load_and_apply() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	var master_db: float = config.get_value("audio", "master_db", 0.0)
	var music_db: float = config.get_value("audio", "music_db", 0.0)
	var sfx_db: float = config.get_value("audio", "sfx_db", 0.0)
	var fullscreen: bool = config.get_value("display", "fullscreen", false)

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), master_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), music_db)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), sfx_db)

	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func save(master_db: float, music_db: float, sfx_db: float, fullscreen: bool) -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_db", master_db)
	config.set_value("audio", "music_db", music_db)
	config.set_value("audio", "sfx_db", sfx_db)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)
