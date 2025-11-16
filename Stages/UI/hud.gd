class_name HUD extends CanvasLayer

@onready var fuel_bar: ProgressBar = $FuelBar
@onready var score_label: Label = $ScoreLabel
@onready var display_text: Label = $DisplayText

func _ready() -> void:
	display_text.hide()

func set_fuel(amount: float, max_fuel: float):
	fuel_bar.max_value = max_fuel
	var tween = get_tree().create_tween()
	tween.tween_property(fuel_bar, "value", amount, 0.2)
	
	if amount < max_fuel * 0.2:
		fuel_bar.modulate = Color.DARK_RED
	else:
		fuel_bar.modulate = Color.WHITE

func set_score(amount: int):
	var formatted_amount = str(amount)
	while formatted_amount.length() < 5:
		formatted_amount = "0" + formatted_amount
	score_label.text = formatted_amount

func display_message(message: String, color: Color):
	display_text.text = message
	display_text.modulate = color
	display_text.modulate.a = 0
	display_text.show()
	var tween = create_tween()
	tween.tween_property(display_text, "modulate:a", 1.0, 0.1)
	tween.tween_interval(1)
	tween.tween_property(display_text, "modulate:a", 0.0, 0.5)
	tween.finished.connect(func(): display_text.hide())
