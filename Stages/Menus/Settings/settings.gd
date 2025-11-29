extends Control

@onready var music_slider: HSlider = $Panel/VBoxContainer/HBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Panel/VBoxContainer/HBoxContainer2/SFXSlider
@onready var back_button: Button = $Panel/VBoxContainer/BackButton
@onready var music_audio_stream_player: AudioStreamPlayer = $MusicAudioStreamPlayer
@onready var sfx_audio_stream_player: AudioStreamPlayer = $SFXAudioStreamPlayer

func _ready() -> void:
	music_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
	sfx_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	
	music_slider.connect("value_changed", Callable(self, "_on_music_changed"))
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_changed"))
	back_button.pressed.connect(_on_back_button_pressed)

func _on_music_changed(value):
	var i = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_db(i, value)
	SettingsManager.save_settings()
	music_audio_stream_player.play()

func _on_sfx_changed(value):
	var i = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(i, value)
	SettingsManager.save_settings()
	sfx_audio_stream_player.play()

func _on_back_button_pressed():
	SceneLoader.load_scene("res://Stages/Menus/TitleScreen/title_screen.tscn")
