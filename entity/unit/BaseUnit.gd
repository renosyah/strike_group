extends BaseEntity
class_name BaseUnit

signal take_damage(_unit, _damage, _from, _by)
signal dead(_unit, _from, _by)
signal reset(_unit)

export var player_id :String
export var team :int = 0
export var speed :int = 1

export var is_dead :bool = false
export var hp :int = 100
export var max_hp :int = 100

export var move_direction :Vector3
export var face_direction :Vector3

export var is_bot :bool = false
export var is_moving :bool = false
export var enable_gravity :bool = true
export var margin :float = 1

var move_to :Vector3
var speed_modifier :float = 1.0

var _pivot :Spatial
var _velocity :Vector3 = Vector3.ZERO
var _momentum :float = 0.0

var _sound :AudioStreamPlayer3D
onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

# performace
var _visibility_notifier :VisibilityNotifier
var _up_direction :Vector3 = Vector3.UP

############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	_pivot = Spatial.new()
	add_child(_pivot)
	_pivot.set_as_toplevel(true)
	
	_sound = AudioStreamPlayer3D.new()
	_sound.bus = "Sfx"
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
	input_ray_pickable = false
	
	_visibility_notifier = VisibilityNotifier.new()
	_visibility_notifier.max_distance = 80
	_visibility_notifier.connect("camera_entered", self, "on_camera_entered")
	_visibility_notifier.connect("camera_exited", self, "on_camera_exited")
	add_child(_visibility_notifier)
	
remotesync func _take_damage(_damage :int, _remain_hp :int, _from :Vector3, _by :String):
	hp = _remain_hp
	emit_signal("take_damage", self, _damage, _from, _by)
	
remotesync func _dead(_from :Vector3, _by :String):
	is_dead = true
	hp = 0
	emit_signal("dead", self, _from, _by)
	
remotesync func _reset():
	is_dead = false
	hp = max_hp
	emit_signal("reset", self)
	
############################################################
# multiplayer func
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if offline_mode:
		return
	
	if not enable_network:
		return
		
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
		
############################################################
func on_camera_entered(_camera :Camera):
	pass
	
func on_camera_exited(_camera :Camera):
	pass

func moving(_delta :float) -> void:
	.moving(_delta)
	
	if is_instance_valid(_visibility_notifier):
		visible = _visibility_notifier.is_on_screen()
	
func master_moving(_delta :float) -> void:
	.master_moving(_delta)
	
	if not enable_network:
		return
		
	_bot_move()
		
	if enable_gravity:
		if is_on_floor():
			_up_direction = get_floor_normal()
			_velocity.y = 0.0
			
		else:
			_up_direction = Vector3.UP
			_velocity.y = lerp(_velocity.y , -_gravity, 0.2)
		
	if is_dead:
		_velocity = _velocity.linear_interpolate(Vector3.ZERO, 1 * _delta)
		
	if move_direction.length() > 0:
		_momentum = lerp(_momentum, 1, 1 * _delta)
		
	else:
		_momentum = 0.0
	
	_velocity = move_and_slide(
		_velocity, _up_direction, true, 4, deg2rad(45.0), true
	)
	
func _bot_move():
	if is_dead:
		return
		
	if is_moving and is_bot:
		var _pos_norm :Vector3 = global_transform.origin * Vector3(1,0,1)
		var _move_to_norm :Vector3 = move_to * Vector3(1,0,1)
		var _dist :float = _pos_norm.distance_to(_move_to_norm)
		var _input_power :float = clamp(_dist * 0.10, 0, 1)
		
		face_direction = _pos_norm.direction_to(_move_to_norm)
		move_direction = Vector3.FORWARD * _input_power
		
		if _dist < margin:
			face_direction = Vector3.ZERO
			move_direction = Vector3.ZERO
			is_moving = false
	
	
func puppet_moving(delta :float) -> void:
	if not enable_network or not _puppet_ready:
		return
		
	translation = translation.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)
	
func turn_spatial_pivot_to_moving(_spatial :Spatial, weight: float):
	if face_direction.length()< 0.3:
		return
		
	var _pos :Vector3 = global_transform.origin
	var _look_at :Vector3 = _pos + face_direction * 100
	_look_at.y = translation.y
	
	_pivot.translation = _pos
	
	_pivot.look_at(_look_at, Vector3.UP)
	_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
	_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -45, 45)
	
	_spatial.rotation.y = lerp_angle(_spatial.rotation.y, _pivot.rotation.y, weight)
	
func get_velocity() -> Vector3:
	return _velocity
	
func has_momentum() -> bool:
	return _momentum > 0.5
	
func take_damage(_damage :int, _from :Vector3, _by :String):
	if is_dead:
		return
		
	hp -= _damage
	
	if offline_mode:
		_take_damage(_damage, hp, _from, _by)
		
	else:
		rpc_unreliable("_take_damage", _damage, hp, _from, _by)
	
	if hp < 0:
		dead(_from, _by)
		
func dead(_from :Vector3, _by :String):
	if not enable_network:
		return
		
	if is_dead:
		return
		
	is_dead = true
	
	if offline_mode:
		_dead(_from, _by)
		
	else:
		rpc("_dead",_from, _by)
	
func reset(_sync :bool = true):
	if not enable_network:
		return
		
	if _sync:
		if offline_mode:
			_reset()
			
		else:
			rpc("_reset")
		
	else:
		_reset()
	





