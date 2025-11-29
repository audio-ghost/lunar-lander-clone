extends Control

@onready var level_select_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/LevelSelectButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/SettingsButton
@onready var test_level_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/TestLevelButton

func _ready() -> void:
	SettingsManager.load_settings()
	level_select_button.pressed.connect(_on_level_select_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	test_level_button.pressed.connect(_on_test_level_pressed)
	level_select_button.grab_focus()

func _on_test_level_pressed():
	SceneLoader.load_scene("res://Stages/world.tscn")

func _on_level_select_pressed():
	SceneLoader.load_scene("res://Stages/Menus/LevelSelect/level_select.tscn")

func _on_settings_pressed():
	SceneLoader.load_scene("res://Stages/Menus/Settings/settings.tscn")
