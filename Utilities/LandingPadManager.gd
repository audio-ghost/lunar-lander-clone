extends Node

var pads: Array[LandingPad] = []

func register_pad(pad: LandingPad) -> void:
	if pad not in pads:
		pads.append(pad)

func unregister_pad(pad: LandingPad) -> void:
	pads.erase(pad)

func all_pads_landed() -> bool:
	for pad in pads:
		if not pad.was_landed:
			return false
	return true
