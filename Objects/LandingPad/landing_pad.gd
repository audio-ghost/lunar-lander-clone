class_name LandingPad extends StaticBody2D

@export var score_value := 10

@onready var scoring_label: Label = $ScoringLabel

func _ready() -> void:
	scoring_label.self_modulate = Color(1, 1, 1, 0.25)
	scoring_label.text = str(score_value)
