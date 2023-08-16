extends Inventory
class_name SupportItem

export var team :int
export var display_area :bool

func use(_enable :bool):
	pass
	
func get_max_cooldown() -> float:
	return 0.0
	
func cooldown_remain() -> float:
	return 0.0
