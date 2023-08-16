extends BaseEntity
class_name BaseBuilding

signal building_selected(_building)
signal building_deployed(_building)
signal building_take_damage(_building, _damage)
signal building_destroyed(_building)

const status_deploying = 0
const status_building = 1
const status_deployed = 2

export var building_id :int = 0
export var team :int = 0
export var color :Color = Color.white

export var hp :int = 500
export var max_hp :int = 500

export var building_time :int = 10

export var is_dead :bool = false
export var status :int = status_deploying
export var can_build :bool = false
export var is_selectable :bool = false
export var enable_gravity :bool = true

puppet var _puppet_translation :Vector3
puppet var _puppet_rotation :Vector3

var _building_timmer :Timer
var _input_detection :Node

var _velocity :Vector3 = Vector3.ZERO
var _up_direction :Vector3 = Vector3.UP

onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

############################################################
# multiplayer func
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if offline_mode:
		return
	
	if is_dead:
		return
		
	if [status_deployed, status_building].has(status):
		return
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
	
# Called when the node enters the scene tree for the first time.
func _ready():
	status = status_deploying
	
	_building_timmer = Timer.new()
	_building_timmer.wait_time = building_time
	_building_timmer.connect("timeout", self , "_building_timmer_timeout")
	_building_timmer.autostart = false
	_building_timmer.one_shot = true
	add_child(_building_timmer)
	
	_input_detection = preload("res://addons/Godot-Touch-Input-Manager/input_detection.tscn").instance()
	_input_detection.connect("any_gesture", self, "_on_input_detection_any_gesture")
	add_child(_input_detection)
	
	input_ray_pickable = is_selectable
	
	set_process(true)
	
func start_building():
	if offline_mode:
		_velocity = Vector3.DOWN
		_start_building()
		return
		
	if not enable_network:
		return
		
	if _is_master:
		_velocity = Vector3.DOWN
		rpc("_start_building")
	
remotesync func _start_building():
	status = status_building
	_building_timmer.wait_time = building_time
	_building_timmer.start()
	#_disable_process()
	
remotesync func _finish_building():
	status = status_deployed
	_disable_process()
	emit_signal("building_deployed", self)
	
remotesync func _take_damage(damage :int, hp_remain :int) -> void:
	hp = hp_remain
	emit_signal("building_take_damage", self, damage)
	
func _disable_process():
	set_process(false)
	
	if _is_master and is_instance_valid(_network_timmer):
		_network_timmer.stop()
		_network_timmer.queue_free()
		
func _building_timmer_timeout():
	if offline_mode:
		_finish_building()
		return
		
	if not enable_network:
		return
		
	if _is_master:
		rpc("_finish_building")
	
func get_build_progress() -> float:
	return _building_timmer.time_left
	
# just to make sure
# building need to touch ground
# and not floating around
func master_moving(_delta :float) -> void:
	if not enable_network:
		return
		
	if enable_gravity:
		if is_on_floor():
			_up_direction = get_floor_normal()
			_velocity.y = 0.0
			
		else:
			_up_direction = Vector3.UP
			_velocity.y = -_gravity
		
	_velocity = move_and_slide(
		_velocity, _up_direction, true, 4, deg2rad(45.0), true
	)
		
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not enable_network:
		return
		
	if is_dead:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)
	
func take_damage(damage :int) -> void:
	if is_dead:
		return
		
	hp -= damage
	
	if offline_mode:
		_take_damage(damage, hp)
		
	else:
		rpc_unreliable("_take_damage", damage, hp)
	
	if hp < 1:
		demolish()
		
func repair() -> void:
	if hp == max_hp:
		return
		
	if offline_mode:
		_repair()
		
	else:
		rpc("_repair")
	
remotesync func _repair() -> void:
	hp = max_hp
	
	# quick trigger
	if offline_mode:
		_take_damage(0, hp)
		
	else:
		rpc_unreliable("_take_damage",0, hp)
	
func demolish() -> void:
	if is_dead:
		return
		
	is_dead = true
	
	if offline_mode:
		_dead()
		
	else:
		rpc("_dead")
	
remotesync func _dead() -> void:
	set_process(false)
	is_dead = true
	emit_signal("building_destroyed", self)
	
func _on_input_event(_camera, event, _position, _normal, _shape_idx):
	if status != status_deployed:
		return
		
	_input_detection.check_input(event)
	
func _on_input_detection_any_gesture(_sig ,event):
	if event is InputEventSingleScreenTap:
		emit_signal("building_selected", self)
		
