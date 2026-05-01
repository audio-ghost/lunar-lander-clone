class_name Stats extends Resource

@export var fuel: float = 1000.0 :
	set(value):
		var previous_fuel: float = fuel
		fuel = value
		if fuel != previous_fuel: fuel_changed.emit(fuel)
		if fuel <= 0: no_fuel.emit()

@export var max_fuel: float = 1000.0

@export var score: int = 0 :
	set(value):
		var previous_score: int = score
		score = value
		if score < 0: score = 0
		if score != previous_score: score_changed.emit(score)

signal fuel_changed(new_fuel: float)
signal no_fuel()

signal score_changed(new_score: int)

func is_fuel_empty() -> bool :
	return fuel < 0.0

func reset() -> void:
	score = 0
	fuel = max_fuel
