class_name LandingPad extends StaticBody2D

@export var pad_width: float = 24.0
@export var first_score_value := 100
@export var score_value := 50
@export var was_landed := false

@onready var scoring_label: Label = $ScoringLabel
@onready var polygon_2d: Polygon2D = $Polygon2D
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

signal landed(pad: LandingPad)

func _ready() -> void:
	LandingPadManager.register_pad(self)
	scoring_label.modulate = Color(1, 1, 1, 0.25)
	scoring_label.text = str(first_score_value)
	update_shape()

func _exit_tree() -> void:
	LandingPadManager.unregister_pad(self)

func update_shape():
	var half = pad_width / 2.0
	var points = [
		Vector2(-half, -4),
		Vector2(half, -4),
		Vector2(half, 4),
		Vector2(-half, 4)
	]
	polygon_2d.polygon = points
	collision_polygon_2d.polygon = points

func get_score_value() -> int:
	if was_landed:
		return score_value
	else:
		return first_score_value 

func process_landing() -> void:
	was_landed = true
	scoring_label.text = str(score_value)
	scoring_label.modulate = Color.GREEN
	scoring_label.modulate.a = 0.25
	polygon_2d.modulate = Color.GREEN
	
	emit_signal("landed", self)
