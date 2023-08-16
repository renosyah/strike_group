extends Spatial
class_name Projectile

signal reach(projectile, target)

export var speed :int = 24
export var margin :float = 0.6
export var max_distance :float = 45
export var spread :float = 0.12
export var is_master :bool

var target # BaseUnit or BaseBuilding

var _launching :bool
var _target_position :Vector3
var _direction :Vector3
var _travel_distance :float

func _ready():
	_launching = false
	set_as_toplevel(true)
	set_process(false)
	
func get_direction() -> Vector3:
	return _direction

func launch():
	_target_position = target.global_transform.origin
	_target_position += _get_spread(_target_position)
	_direction = _get_pos().direction_to(_target_position)
	_travel_distance = 0
	_launching = true
	set_process(true)
	
func _get_spread(pos :Vector3) -> Vector3:
	return _get_pos().direction_to(pos) * 10 + Vector3.ONE * rand_range(-spread, spread)

func is_launching() -> bool:
	return _launching
	
func _get_pos() -> Vector3:
	return global_transform.origin
	
func _process(delta):
	projectile_travel(delta)
	
func projectile_travel(delta):
	# update target position
	if is_instance_valid(target):
		_target_position = target.global_transform.origin
		
	if _travel_distance > max_distance:
		_launching = false
		projectile_dismiss()
		set_process(false)
		return
		
	if _get_pos().distance_to(_target_position) < margin:
		_reach()
		_launching = false
		projectile_dismiss()
		set_process(false)
		return
		
	_travel_distance += speed * delta
	translation += _direction * speed * delta
	
func _reach():
	emit_signal("reach", self, target)
	
func projectile_dismiss():
	pass
	













