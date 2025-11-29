extends CanvasLayer

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var restart_button: Button = $VBoxContainer/HBoxContainer/RestartButton
@onready var level_select_button: Button = $VBoxContainer/HBoxContainer/LevelSelectButton
@onready var quit_button: Button = $VBoxContainer/HBoxContainer/QuitButton
@onready var high_scores_label: Label = $VBoxContainer/HighScoresLabel
@onready var name_entry_container: BoxContainer = $VBoxContainer/NameEntryContainer
@onready var name_entry_line_edit: LineEdit = $VBoxContainer/NameEntryContainer/NameEntryLineEdit
@onready var name_entry_button: Button = $VBoxContainer/NameEntryContainer/NameEntryButton
@onready var high_scores_display: HighScoresDisplay = $VBoxContainer/HighScoresDisplay

var current_level_name := ""
var is_complete := false
var pending_score := 0

func setup(level_complete: bool, score: int, level_name: String):
	current_level_name = level_name
	is_complete = level_complete
	
	title_label.text = "Level Complete!" if level_complete else "Game Over"
	score_label.text = "Score: %d" % score
	visible = true
	
	if HighScoreManager.is_high_score(current_level_name, score):
		ask_for_name(score)
	else:
		high_scores_display.show_high_scores(current_level_name)
		restart_button.grab_focus()

func ask_for_name(score: int):
	name_entry_container.visible = true
	name_entry_line_edit.text = ""
	name_entry_line_edit.grab_focus()
	pending_score = score

func _on_name_submit_pressed():
	var name = name_entry_line_edit.text.strip_edges()
	if name == "":
		name == "AAA"
	
	HighScoreManager.add_score(current_level_name, name, pending_score)
	
	name_entry_container.visible = false
	high_scores_display.show_high_scores(current_level_name)
	restart_button.grab_focus()


func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	level_select_button.pressed.connect(_on_level_select_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	name_entry_button.pressed.connect(_on_name_submit_pressed)

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_level_select_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Stages/LevelSelect/level_select.tscn")

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Stages/TitleScreen/title_screen.tscn")
