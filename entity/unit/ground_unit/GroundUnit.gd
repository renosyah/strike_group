extends BaseUnit
class_name GroundUnit

export var attack_damage :int
export var attack_delay :float
export var attack_range :float
export var color_coat :Color

var target # BaseUnit or BaseBuilding
var final_attack_range :float
var final_attack_delay :float
var min_attack_range :float = 2
var force_bot_move :bool

var unit_spotter :UnitSpotter

var _attack_delay_timer :Timer
var _hit_particle :HitParticle
var _animation_states :Dictionary = {}
var _aim_align :bool

func _ready():
	enable_gravity = true
	is_moving = false
	margin = 0.3
	
	_attack_delay_timer = Timer.new()
	_attack_delay_timer.wait_time = attack_delay
	_attack_delay_timer.one_shot = true
	add_child(_attack_delay_timer)
	
	_hit_particle = preload("res://assets/visual_effect/hit_particle/hit_particle.tscn").instance()
	_hit_particle.custom_particle_scene =  preload("res://assets/visual_effect/hit_particle/custom_particle/text/custom_text_particle.tscn")
	add_child(_hit_particle)
	_hit_particle.set_as_toplevel(true)
	
	if _check_is_master():
		unit_spotter = preload("res://assets/utils/spotter/unit_spotter.tscn").instance()
		unit_spotter.team = team
		unit_spotter.ignore_body = self
		add_child(unit_spotter)
		unit_spotter.set_enable(true)
		
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if offline_mode:
		return
	
	if not enable_network:
		return
		
	if not _is_master or not _is_online:
		return
		
	var _target_path :NodePath
	
	if is_instance_valid(target):
		_target_path = target.get_path()
		
	rset_unreliable("_puppet_target", _target_path)
	rset_unreliable("_puppet_aim_align", _aim_align)
	rset_unreliable("_puppet_animation_states", _animation_states)
	
# multiplayer func
puppet var _puppet_target :NodePath
puppet var _puppet_aim_align :bool
puppet var _puppet_animation_states :Dictionary

remotesync func _take_damage(_damage :int, _remain_hp :int, _from :Vector3, _by :String):
	._take_damage(_damage, _remain_hp, _from, _by)
	
	if _damage > 0:
		_hit_particle.display_hit(
			"-%s" % _damage, Color.orangered, global_transform.origin
		)
		
remotesync func _dead(_from :Vector3, _by :String):
	._dead(_from, _by)
	
	if is_instance_valid(unit_spotter):
		unit_spotter.set_enable(false)
	
remotesync func _reset():
	._reset()
	
	if is_instance_valid(unit_spotter):
		unit_spotter.set_enable(true)
	
func master_moving(delta :float) -> void:
	if is_dead:
		.master_moving(delta)
		return
		
	if translation.y < -4:
		dead(Vector3.DOWN, player_id)
		return
		
	_check_target()
	
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	var _basis_direction :Vector3 = -global_transform.basis.z
	var _move :Vector3 = _basis_direction * _input_power * (speed * speed_modifier)
	_velocity = Vector3(_move.x, _velocity.y, _move.z)
	
	turn_spatial_pivot_to_moving(self, speed * delta)
	.master_moving(delta)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not enable_network or not _puppet_ready:
		return
		
	target = get_node_or_null(_puppet_target)
	_animation_states = _puppet_animation_states
	_aim_align = _puppet_aim_align
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if is_dead:
		return
	
	if not is_instance_valid(target):
		return
		
	if target.is_dead:
		return
		
	var target_pos :Vector3
	
	if target is BaseUnit:
		target_pos = target.global_transform.origin
		
	elif target is BaseBuilding:
		target_pos = target.global_transform.origin
		
	var pos :Vector3 = global_transform.origin
	
	if pos.distance_to(target_pos) > final_attack_range:
		return
		
	# yes, i know, this fix
	# just to make all sync
	if _is_master:
		_aim_align = _is_align(target_pos)
		
	if not _aim_align:
		return
		
	if _attack_delay_timer.is_stopped():
		perform_attack()
		
		
func _bot_move():
	if is_dead:
		return
		
	if not is_bot:
		return
		
	if final_attack_range < 5 or force_bot_move:
		._bot_move()
		return
		
	if not is_instance_valid(target):
		._bot_move()
		return
		
	var _pos :Vector3 = global_transform.origin
	var _target_pos :Vector3 = target.global_transform.origin
	var _direction_to_target :Vector3 = _pos.direction_to(_target_pos) * Vector3(1,0,1)
	var _dist :float = _pos.distance_to(_target_pos)
	var _input_power :float = clamp(_dist * 0.10, 0, 1)
	var _is_in_range :bool = _dist <= final_attack_range
	
	face_direction = _direction_to_target
	move_direction = Vector3.ZERO if _is_in_range else (_direction_to_target * _input_power)
	
func _is_align(_target_pos :Vector3) -> bool:
	var _from_pos :Vector3 = global_transform.origin
	var _dist :float = _from_pos.distance_to(_target_pos)
	var _to_pos :Vector3 = _from_pos + -global_transform.basis.z * _dist
	_to_pos.y = _target_pos.y
	return _to_pos.distance_to(_target_pos) < 2
	
func _check_target():
	target = null
	
	target =_get_closes_target(
		global_transform.origin,
		unit_spotter.get_alive_unit_targets()
	)
	
	if is_instance_valid(target):
		return
		
	target =_get_closes_target(
		global_transform.origin,
		unit_spotter.get_alive_building_targets()
	)
	
func _get_closes_target(from :Vector3, _targets :Array) -> BaseUnit:
	if _targets.empty():
		return null
		
	var final_target :BaseUnit = null
	
	for new_target in _targets:
		if new_target.is_dead:
			continue
			
		if not is_instance_valid(final_target):
			final_target = new_target
			continue
			
		var dis_1 = from.distance_squared_to(final_target.global_transform.origin)
		var dis_2 = from.distance_squared_to(new_target.global_transform.origin)
		
		if dis_2 < dis_1:
			final_target = new_target
			
	return final_target

func perform_attack():
	_attack_delay_timer.start()
