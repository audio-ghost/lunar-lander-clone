extends Node2D

@onready var label: Label = $Label

func show_points(amount: int) -> void:
	label.text = str(amount)
	if amount >= 0:
		modulate = Color.GREEN
	else:
		modulate = Color.RED
	run_animation()

func run_animation() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 40, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 1.0)
	
	tween.finished.connect(queue_free)
