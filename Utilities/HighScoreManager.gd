extends Node

const SAVE_PATH: String = "user://Data/high_scores.json"
const DEFAULT_PATH: String = "res://Utilities/Data/default_high_scores.json"
const MAX_SCORES: int = 5

var scores: Dictionary[String, HighScoreList] = {}  # Dictionary: { "level_name": [ { "name": "AAA", "score": 12345 }, ... ] }


func _ready() -> void:
	var dir: DirAccess = DirAccess.open("user://")
	dir.make_dir_recursive("Data")
	load_scores()


func load_scores() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	if file == null:
		_create_default_file()
		file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	
	var content: String = file.get_as_text()
	file.close()
	
	var parsed: Variant = JSON.parse_string(content)
	
	if parsed == null or not parsed is Dictionary:
		scores = {}
		return
	
	scores.clear()
	
	for level: String in parsed.keys():
		var list: HighScoreList = HighScoreList.new()
		var raw_array: Array = parsed[level]
		
		for entry_dict: Variant in raw_array:
			if not entry_dict is Dictionary:
				continue
			
			var entry: HighScoreEntry = HighScoreEntry.new()
			var player_name: String = entry_dict.get("name", "")
			entry.name = player_name
			var score: int = entry_dict.get("score", 0)
			entry.score = score
			list.entries.append(entry)
		
		scores[level] = list


func _create_default_file() -> void:
	var default_file: FileAccess = FileAccess.open(DEFAULT_PATH, FileAccess.READ)
	if default_file == null:
		push_error("Default high score file missing! Cannot initialize.")
		return
	
	var contents: String = default_file.get_as_text()
	default_file.close()
	
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	save_file.store_string(contents)
	save_file.close()


func save_scores() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	
	var output: Dictionary = {}
	
	for level: String in scores.keys():
		var list: HighScoreList = scores[level]
		var arr: Array = []
		
		for entry: HighScoreEntry in list.entries:
			arr.append({
				"name": entry.name,
				"score": entry.score
			})
		
		output[level] = arr
		
	file.store_string(JSON.stringify(output, "\t"))
	file.close()


func get_scores(level_name: String) -> HighScoreList:
	if not scores.has(level_name):
		scores[level_name] = HighScoreList.new()
	return scores[level_name]


func is_high_score(level_name: String, score: int) -> bool:
	var list: HighScoreList = get_scores(level_name)
	if list.entries.size() < MAX_SCORES:
		return true
	return score > list.entries.back().score


func add_score(level_name: String, player_name: String, score: int) -> void:
	var list: HighScoreList = get_scores(level_name)
	var new_high_score: HighScoreEntry = HighScoreEntry.new()
	new_high_score.name = player_name
	new_high_score.score = score
	list.entries.append(new_high_score)
	
	#sort list highest to lowest
	list.entries.sort_custom(
		func(a: HighScoreEntry, b: HighScoreEntry) -> bool: return a.score > b.score
	)
	
	# trim list
	if list.entries.size() > MAX_SCORES:
		list.entries.resize(MAX_SCORES)
		
	scores[level_name] = list
	save_scores()
