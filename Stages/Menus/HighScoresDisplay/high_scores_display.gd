class_name HighScoresDisplay extends VBoxContainer

@onready var high_scores_label: Label = $HighScoresLabel
@onready var scores_list: VBoxContainer = $ScoresList

func show_high_scores(current_level_name: String) -> void:
	var scores: HighScoreList = HighScoreManager.get_scores(current_level_name)
	for child: Node in scores_list.get_children():
		child.queue_free()
	
	if scores.entries.is_empty():
		var empty_label: Label = Label.new()
		high_scores_label.text = "No high scores yet."
		scores_list.add_child(empty_label)
		return
	
	high_scores_label.text = "High Scores for %s:" % current_level_name
	for entry: HighScoreEntry in scores.entries:
		# entry should be { "name": name, "score": score }
		var row: HBoxContainer = HBoxContainer.new()

		var name_label: Label = Label.new()
		name_label.text = entry.name
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var score_label: Label = Label.new()
		score_label.text = str(entry.score)
		score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

		row.add_child(name_label)
		row.add_child(score_label)

		scores_list.add_child(row)
