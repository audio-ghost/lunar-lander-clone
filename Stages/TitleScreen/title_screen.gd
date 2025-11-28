extends Control

@onready var start_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/StartButton
@onready var level_select_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/LevelSelectButton
@onready var high_scores_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/HighScoresButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer2/VBoxContainer/SettingsButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	high_scores_button.pressed.connect(_on_high_scores_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	start_button.grab_focus()

func _on_start_pressed():
	SceneLoader.load_scene("res://Stages/world.tscn")

func _on_level_select_pressed():
	SceneLoader.load_scene("res://Stages/LevelSelect/level_select.tscn")

func _on_high_scores_pressed():
	# TODO - Implement High Scores Screen
	pass

func _on_settings_pressed():
	# TODO - Implement Settings Screen
	pass
