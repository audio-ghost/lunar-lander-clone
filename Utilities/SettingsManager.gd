extends Node

const SAVE_PATH = "user://Data/settings.cfg"

func save_settings():
	var config = ConfigFile.new()
	
	var music = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	var sfx = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	
	config.set_value("audio", "music", music)
	config.set_value("audio", "sfx", sfx)
	
	config.save(SAVE_PATH)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK:
		return # First run - no settings yet
	
	if config.has_section_key("audio", "music"):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Music"),
			config.get_value("audio", "music")
		)
	if config.has_section_key("audio", "sfx"):
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("SFX"),
			config.get_value("audio", "sfx")
		)
