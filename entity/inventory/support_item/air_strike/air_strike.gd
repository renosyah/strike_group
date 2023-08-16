extends SupportItem

export var air_strike_max_ammo :int = 10
export var attack_damage :int = 180

onready var cooldown_timer = $cooldown_timer
onready var aiming_timer = $aiming_timer
onready var area = $area
onready var collision_shape = $area/CollisionShape
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var animation_player = $AnimationPlayer
onready var aiming_template = $aiming_template
onready var delay_timer = $delay_timer

var _ammos :Array = []
var _aims :Array = []

func _ready():
	audio_stream_player_3d.unit_size = 5
	_enable_detection(false)
	
func _enable_detection(_enable :bool):
	area.set_deferred("monitoring", _enable)
	collision_shape.set_deferred("disabled", not _enable)
	
func prepare_ammo():
	if not _ammos.empty():
		return
		
	var last_index = get_tree().get_root().get_child_count() - 1
	
	for _i in range(air_strike_max_ammo):
		var missile = preload("res://entity/projectile/missile_ammo/missile_ammo.tscn").instance()
		missile.connect("reach", self , "_on_missile_reach_target")
		get_tree().get_root().get_child(last_index).add_child(missile)
		_ammos.append(missile)
		
		var aim = aiming_template.duplicate()
		add_child(aim)
		aim.set_as_toplevel(true)
		_aims.append(aim)
		
func use(_enable :bool):
	.use(_enable)
	
	prepare_ammo()
	
	if display_area:
		animation_player.play("bip")
	
	if _enable:
		cooldown_timer.start()
		aiming_timer.start()
		
	else:
		for i in _aims:
			i.visible = false
		
		cooldown_timer.stop()
		aiming_timer.stop()
		
		
	_enable_detection(_enable)
	
func get_max_cooldown() -> float:
	return cooldown_timer.wait_time
	
func cooldown_remain() -> float:
	return cooldown_timer.time_left
	
func _on_cooldown_timer_timeout():
	_attack_unit_in_area()
	
	animation_player.play("incoming")
	yield(animation_player,"animation_finished")
	
	animation_player.play("bip")
	cooldown_timer.start()
	
func _on_aiming_timer_timeout():
	if display_area and not audio_stream_player_3d.playing:
		audio_stream_player_3d.stream = preload("res://assets/sounds/support_item/beep_2.wav")
		audio_stream_player_3d.play()
	
	if not is_master:
		return
		
	var units :Array = _get_unit_in_area()
	for i in _aims:
		i.visible = false
		
	for i in range(units.size()):
		var aim = _aims[i]
		aim.visible = true
		aim.translation = units[i].global_transform.origin
		
	aiming_timer.start()
	
func _attack_unit_in_area():
	var _units :Array = _get_unit_in_area()
	_units.shuffle()
	
	_perform_airstrike(_units)
	
func _get_unit_in_area() -> Array:
	var _units :Array = []
	for body in area.get_overlapping_bodies():
		if _units.size() >= air_strike_max_ammo:
			break
			
		if body is BaseUnit:
			if body.team == team:
				continue
				
			if body.is_dead:
				continue
				
			_units.append(body)
			
		elif body is BaseBuilding:
			if body.team == team:
				continue
				
			if body.is_dead:
				continue
				
			_units.append(body)
			
	return _units
	
func _perform_airstrike(_units :Array):
	if _units.empty():
		return
		
	audio_stream_player_3d.stream = preload("res://assets/sounds/support_item/confirm_air_strike.wav")
	audio_stream_player_3d.play()
	
	for i in _units:
		var _target :BaseUnit = i
		
		delay_timer.start()
		yield(delay_timer, "timeout")
		
		_launch_idle_missile(_target)
		
func _launch_idle_missile(_target :BaseUnit):
	for i in _ammos:
		var missile :Projectile = i
		if missile.is_launching():
			continue
			
		missile.target = _target
		missile.translation = _target.global_transform.origin + Vector3(15, 60, 15)
		missile.speed = 18
		missile.max_distance = 200
		missile.launch()
		return
	
func _on_missile_reach_target(_projectile :Projectile, _target):
	if not is_master:
		return
		
	if not is_instance_valid(_target):
		return
		
	var modifier :int = int(attack_damage * 0.25)
	var damage :int = int(rand_range(attack_damage - modifier,attack_damage + modifier))
	
	if _target is BaseUnit:
		_target.take_damage(damage, _projectile.get_direction(), player_id)
		
	elif _target is BaseBuilding:
		# damage to building should be diffrent
		# latter maybe
		_target.take_damage(damage)
	

























