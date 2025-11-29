extends Node2D

var end_screen = preload("res://Stages/GameEndScreen/game_end_screen.tscn")

@onready var player: Player = $Player
@onready var background_texture_rect: TextureRect = $BackgroundTextureRect

func _ready():
	player.stats.reset()
	player.player_game_over.connect(_on_player_game_over)
	player.player_level_complete.connect(_on_player_level_complete)

func _process(delta: float) -> void:
	background_texture_rect.rotation += 0.01 * delta

func show_game_end_screen(is_level_complete: bool, score: int):
	var screen = end_screen.instantiate()
	add_child(screen)
	var level_name : String = get_scene_file_path().get_file().get_basename()
	screen.setup(is_level_complete, score, level_name)


func _on_player_game_over(score):
	show_game_end_screen(false, score)

func _on_player_level_complete(score):
	show_game_end_screen(true, score)
