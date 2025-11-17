class_name HUD extends CanvasLayer

@onready var fuel_bar: ProgressBar = $FuelBar
@onready var score_label: Label = $ScoreLabel
@onready var display_text: Label = $DisplayText

var message_queue: Array = []
var is_showing_message: bool = false

func _ready() -> void:
	reset_message()

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
	message_queue.append({"text": message, "color": color})
	if not is_showing_message:
		_show_next_message()
	
func _show_next_message():
	if message_queue.is_empty():
		is_showing_message = false
		return
	
	is_showing_message = true
	
	var message = message_queue.pop_front()
	display_text.text = message["text"]
	display_text.modulate = message["color"]
	display_text.modulate.a = 0
	display_text.show()
	
	var tween = create_tween()
	tween.tween_property(display_text, "modulate:a", 1.0, 0.1)
	tween.tween_interval(1)
	tween.tween_property(display_text, "modulate:a", 0.0, 0.5)
	tween.finished.connect(reset_message)

func reset_message():
	display_text.hide()
	_show_next_message()
