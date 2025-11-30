class_name PauseMenu extends Control

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var level_select_button: Button = $Panel/VBoxContainer/LevelSelectButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

func _ready() -> void:
	visible = false
	
	resume_button.pressed.connect(_on_resume_button_pressed)
	level_select_button.pressed.connect(_on_level_select_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func open():
	visible = true
	get_tree().paused = true
	resume_button.grab_focus()

func close():
	get_tree().paused = false
	visible = false

func _on_resume_button_pressed():
	close()

func _on_level_select_button_pressed():
	get_tree().paused = false
	SceneLoader.load_scene("res://Stages/Menus/LevelSelect/level_select.tscn")

func _on_quit_button_pressed():
	get_tree().paused = false
	SceneLoader.load_scene("res://Stages/Menus/TitleScreen/title_screen.tscn")
