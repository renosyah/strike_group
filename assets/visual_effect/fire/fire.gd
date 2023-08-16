extends Spatial

onready var _fire = $fire

func set_is_burning(val :bool):
	_fire.emitting = val
