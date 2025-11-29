extends Node

const SAVE_PATH := "user://Data/high_scores.json"
const DEFAULT_PATH := "res://Utilities/Data/default_high_scores.json"
const MAX_SCORES := 5

var scores := {}  # Dictionary: { "level_name": [ { "name": "AAA", "score": 12345 }, ... ] }

func _ready() -> void:
	var dir := DirAccess.open("user://")
	dir.make_dir_recursive("Data")
	load_scores()

func load_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file == null:
		_create_default_file()
		file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	var content = file.get_as_text()
	file.close()
	
	scores = JSON.parse_string(content)
	
	if scores == null:
		scores = {}
	else:
		for level in scores.keys():
			for entry in scores[level]:
				entry["score"] = int(entry["score"])

func _create_default_file():
	var default_file := FileAccess.open(DEFAULT_PATH, FileAccess.READ)
	if default_file == null:
		push_error("Default high score file missing! Cannot initialize.")
		return
	
	var contents := default_file.get_as_text()
	default_file.close()
	
	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_file.store_string(contents)
	save_file.close()

func save_scores():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file: print(file)
	else: print("No file!")
	file.store_string(JSON.stringify(scores, "\t"))
	file.close()

func get_scores(level_name: String) -> Array:
	if not scores.has(level_name):
		scores[level_name] = []
	return scores[level_name]

func is_high_score(level_name: String, score: int) -> bool:
	var list = get_scores(level_name)
	if list.size() < MAX_SCORES:
		return true
	return score > list.back().score

func add_score(level_name: String, player_name: String, score: int):
	var list = get_scores(level_name)
	list.append({"name": player_name, "score": score})
	
	#sort list highest to lowest
	list.sort_custom(func(a, b): return a.score > b.score)
	
	# trim list
	if list.size() > MAX_SCORES:
		list.resize(MAX_SCORES)
		
	scores[level_name] = list
	save_scores()
