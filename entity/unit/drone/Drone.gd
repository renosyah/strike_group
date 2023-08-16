extends BaseUnit
class_name Drone

onready var shot_sound = preload("res://assets/sounds/weapon/smg/shot.wav")

onready var unit_spotter = $unit_spotter
onready var attack_delay = $attack_delay
onready var position_3d = $Position3D
onready var explosion_1 = $Explosion1
onready var spatial = $Spatial
onready var icon = $Spatial/icon
onready var buzz_noise = $buzz_noise

export var attack_damage :int = 15
export var altitude :float = 3

var target # BaseUnit or BaseBuilding
var active :bool

var _bullets :Array = []

# multiplayer func
puppet var _puppet_target :NodePath

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if not active:
		return
	
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
	
remotesync func _dead(_from :Vector3, _by :String):
	._dead(_from, _by)
	destroy()
	
func _ready():
	prepare_projectile()
	enable_gravity = false
	
	var is_master = _check_is_master()
	icon.visible = is_master
	unit_spotter.set_enable(is_master)
	set_active(false)
	
func set_team(_team :int):
	team = _team
	unit_spotter.team = _team
	
func set_active(val :bool):
	active = val
	spatial.visible = active
	set_process(active)
	
	if val:
		buzz_noise.play()
		
	else:
		buzz_noise.stop()
	
func destroy():
	explosion_1.emitting = true
	
	_sound.stream = preload("res://assets/sounds/explosions/explosion_1.wav")
	_sound.play()
	
	set_active(false)
	
	yield(get_tree().create_timer(2),"timeout")
	translation = global_transform.origin + Vector3(0, 50, 0)
	
func prepare_projectile():
	var last_index = get_tree().get_root().get_child_count() - 1
	
	for _i in 10:
		var bullet :Projectile = preload("res://entity/projectile/bullet/bullet.tscn").instance()
		bullet.connect("reach", self , "on_bullet_reach_target")
		get_tree().get_root().get_child(last_index).add_child(bullet)
		_bullets.append(bullet)
		
func on_bullet_reach_target(_projectile :Projectile, _target):
	if not _is_master:
		return
		
	if not is_instance_valid(_target):
		return
		
	var modifier :int = int(attack_damage * 0.25)
	var damage :int = int(rand_range(attack_damage - modifier, attack_damage + modifier))
	
	if _target is BaseUnit:
		_target.take_damage(damage, _projectile.get_direction(), player_id)
		
		
func master_moving(delta :float) -> void:
	if active:
		_check_target()
		var _input_power :float = move_direction.length()
		var _is_moving :bool = _input_power > 0.1
		var _basis_direction :Vector3 = -global_transform.basis.z
		var _move :Vector3 = _basis_direction * _input_power * (speed * speed_modifier)
		_velocity = Vector3(_move.x, _velocity.y, _move.z)
		
		turn_spatial_pivot_to_moving(self, speed * delta)
		translation.y = lerp(translation.y, move_to.y + altitude, 1 * delta)
	
	.master_moving(delta)
	
func moving(delta:float) -> void:
	.moving(delta)
	
	if active:
		_attack_target()
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not enable_network or not _puppet_ready:
		return
		
	target = get_node_or_null(_puppet_target)
	
func _attack_target():
	if is_instance_valid(target):
		if attack_delay.is_stopped():
			_shot()
			
			_sound.stream = shot_sound
			_sound.play()
			
			attack_delay.start()
	
func _shot():
	for i in _bullets:
		var bullet :Projectile = i
		if bullet.is_launching():
			continue
			
		bullet.target = target
		bullet.spread = 0.12
		bullet.translation = position_3d.global_transform.origin
		bullet.launch()
		return
	
func queue_free():
	for i in _bullets:
		i.queue_free()
		
	.queue_free()
	
func _check_target():
	target = null
	
	target =_get_closes_target(
		global_transform.origin,
		unit_spotter.get_alive_unit_targets()
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
