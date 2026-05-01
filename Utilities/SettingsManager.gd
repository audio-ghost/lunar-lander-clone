extends Node

const SAVE_PATH: String = "user://Data/settings.cfg"

func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	var music: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var sfx: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	
	config.set_value("audio", "music", music)
	config.set_value("audio", "sfx", sfx)
	
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	
	if err != OK:
		return # First run - no settings yet
	
	if config.has_section_key("audio", "music"):
		var music_value: float = config.get_value("audio", "music")
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_value)
	if config.has_section_key("audio", "sfx"):
		var sfx_value: float = config.get_value("audio", "sfx")
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfx_value)
