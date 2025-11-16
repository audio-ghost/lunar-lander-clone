class_name Stats extends Resource

@export var fuel := 1000.0 :
	set(value):
		var previous_fuel = fuel
		fuel = value
		if fuel != previous_fuel: fuel_changed.emit(fuel)
		if fuel <= 0: no_fuel.emit()

@export var max_fuel := 1000.0

@export var score := 0 :
	set(value):
		var previous_score = score
		score = value
		if score < 0: score = 0
		if score != previous_score: score_changed.emit(score)

signal fuel_changed(new_fuel)
signal no_fuel()

signal score_changed(new_score)

func is_fuel_empty() -> bool :
	return fuel < 0.0
