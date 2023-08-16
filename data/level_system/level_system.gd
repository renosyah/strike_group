extends Node
class_name LevelSystem

const stater_count :int = 5
const stater_level_increment :float = 0.05

const level_increment :float = 0.10
const level_increment_low :float = 0.01

static func get_value(level :int, to):
	if to is int:
		var temp :int = to
		var final_value :float = float(to)
		for _i in range(level):
			final_value += temp * level_increment
			
		return int(final_value)
		
	elif to is float:
		var temp :float = to
		var is_below :bool = temp < 0.0
		var final_value :float = to
		for _i in range(level):
			if is_below:
				final_value = final_value + (temp * level_increment)
				
			else:
				final_value = clamp(final_value + (temp * level_increment_low), 0.1, 0.99)
			
		return float(final_value)
		
	return to
