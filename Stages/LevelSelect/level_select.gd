extends Control

@onready var level_grid: GridContainer = $MarginContainer/VBoxContainer/LevelGrid
@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton

var level_data = [
	{
		"name": "Level 1",
		"path": "res://Stages/Levels/level1.tscn"
	},
	{
		"name": "Level 2",
		"path": "res://Stages/Levels/level2.tscn"
	},
	{
		"name": "Level 3",
		"path": "res://Stages/Levels/level3 .tscn"
	},
	{
		"name": "Level 4",
		"path": "res://Stages/Levels/level4.tscn"
	},
	{
		"name": "Level 5",
		"path": "res://Stages/Levels/level5.tscn"
	}
]

func _ready() -> void:
	_build_level_buttons()
	back_button.pressed.connect(_on_back_button_pressed)

func _build_level_buttons():
	var level_button_scene = load("res://Stages/LevelSelect/Data/level_button.tscn")
	
	for lvl in level_data:
		var btn = level_button_scene.instantiate()
		btn.level_name = lvl["name"]
		btn.level_path = lvl["path"]
		
		btn.pressed.connect(func():
			SceneLoader.load_scene(lvl["path"])
		)
		
		level_grid.add_child(btn)

func _on_back_button_pressed():
	SceneLoader.load_scene("res://Stages/TitleScreen/title_screen.tscn")
