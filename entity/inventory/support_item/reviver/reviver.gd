extends SupportItem

onready var healing_timer = $healing_timer
onready var mesh_instance_3 = $MeshInstance3
onready var area = $area
onready var animation_player = $MeshInstance3/AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var beep_time = $beep_time
onready var collision_shape = $area/CollisionShape

func _ready():
	mesh_instance_3.visible = false
	audio_stream_player_3d.unit_size = 5
	mesh_instance_3.set_as_toplevel(true)
	_enable_detection(false)
	
func _enable_detection(_enable :bool):
	area.set_deferred("monitoring", _enable)
	collision_shape.set_deferred("disabled", not _enable)
	

func _process(_delta):
	mesh_instance_3.translation = global_transform.origin

func use(_enable :bool):
	.use(_enable)
	
	if not is_master:
		return
		
	if _enable:
		healing_timer.start()
		beep_time.start()
		
	else:
		healing_timer.stop()
		beep_time.stop()
		
	_enable_detection(_enable)
	
func get_max_cooldown() -> float:
	return healing_timer.wait_time
	
func cooldown_remain() -> float:
	return healing_timer.time_left
	
func _on_healing_timer_timeout():
	_heal_unit_in_area()
	
	if display_area:
		audio_stream_player_3d.stream = preload("res://assets/sounds/support_item/revive.wav")
		audio_stream_player_3d.play()
	
		animation_player.play("heal")
	
	healing_timer.start()
	beep_time.start()
	
func _on_beep_time_timeout():
	beep_time.start()
	
	if audio_stream_player_3d.playing:
		return
		
	if display_area:
		audio_stream_player_3d.stream = preload("res://assets/sounds/support_item/beep.wav")
		audio_stream_player_3d.play()
	
func _heal_unit_in_area():
	var _units :Array = []
	
	for body in area.get_overlapping_bodies():
		if body is Infantry:
			_units.append(body)
			
		# bonus lol
		elif body is PlantExplosive:
			if body.is_deployed():
				body.explode()
				
	if is_master:
		for i in _units:
			var unit: Infantry = i
			if unit.team == team:
				if unit.is_dead:
					unit.reset()
			else:
				if not unit.is_dead:
					var unit_pos :Vector3 = unit.global_transform.origin
					var dir :Vector3 = global_transform.origin.direction_to(unit_pos)
					unit.take_damage(unit.max_hp + 10, dir, player_id)
















