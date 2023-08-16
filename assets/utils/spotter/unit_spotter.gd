extends Area
class_name UnitSpotter

signal on_target_added(_target)
signal on_target_removed(_target)

export var detection_range :int = 8
export var team :int

var _unit_targets :Array = []
var _building_targets :Array = []
var ignore_body

onready var _collision_shape = $CollisionShape
onready var _shape :CylinderShape = (_collision_shape.shape as CylinderShape).duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	_collision_shape.shape = _shape
	_shape.radius = detection_range
	
func set_enable(_enable :bool):
	set_deferred("monitoring", _enable)
	_collision_shape.set_deferred("disabled", not _enable)
	_unit_targets.clear()
	_building_targets.clear()
	
func set_detection_range(size :int):
	_shape.radius = size
	
func get_alive_unit_targets() -> Array:
	var _alive_unit_targets :Array = []
	
	if not monitoring:
		return _alive_unit_targets
	
	for i in _unit_targets:
		var unit :BaseUnit = i
		if not unit.is_dead:
			_alive_unit_targets.append(unit)
			
	return _alive_unit_targets
	
func get_alive_building_targets() -> Array:
	var _alive_building_targets :Array = []
	
	if not monitoring:
		return _alive_building_targets
		
	for i in _building_targets:
		var building :BaseBuilding = i
		if not building.is_dead:
			_alive_building_targets.append(building)
			
	return _alive_building_targets
	
func append_targets(bodies :Array):
	for body in bodies:
		_on_spotter_body_entered(body)
		
func remove_targets(bodies :Array):
	for body in bodies:
		_on_spotter_body_exited(body)
	
func _on_spotter_body_entered(body):
	if body == ignore_body:
		return
		
	_check_is_unit(body)
	_check_is_building(body)
	
func _check_is_unit(body):
	if not body is BaseUnit:
		return
		
	if body.team == team:
		return
	
	if _unit_targets.has(body):
		return
		
	_unit_targets.append(body)
	
	emit_signal("on_target_added",body)
	
func _check_is_building(body):
	if not body is BaseBuilding:
		return
		
	if body.team == team:
		return
		
	if _building_targets.has(body):
		return
		
	_building_targets.append(body)
	
	emit_signal("on_target_added",body)
	
func _on_spotter_body_exited(body):
	if _unit_targets.has(body):
		_unit_targets.erase(body)
		
	if _building_targets.has(body):
		_building_targets.erase(body)
		
	emit_signal("on_target_removed",body)
	
	























