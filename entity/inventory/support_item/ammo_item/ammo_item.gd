extends SupportItem

const rearm_sound = [
	preload("res://assets/sounds/support_item/rearm_1.wav"),
	preload("res://assets/sounds/support_item/rearm_2.wav"),
	preload("res://assets/sounds/support_item/rearm_3.wav")
]

onready var rearm_timer = $rearm_timer
onready var mesh_instance_3 = $MeshInstance3
onready var area = $area
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var collision_shape = $area/CollisionShape

func _ready():
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
	
	mesh_instance_3.visible = _enable and display_area
	
	if _enable:
		rearm_timer.start()
		
	else:
		rearm_timer.stop()
		
	_enable_detection(_enable)
	
func get_max_cooldown() -> float:
	return rearm_timer.wait_time
	
func cooldown_remain() -> float:
	return rearm_timer.time_left


func _on_rearm_timer_timeout():
	if is_master:
		_rearm_unit_in_area()
		
	if display_area:
		audio_stream_player_3d.stream = rearm_sound[rand_range(0, rearm_sound.size())]
		audio_stream_player_3d.play()
	
	rearm_timer.start()
	
func _rearm_unit_in_area():
	var _units :Array = []
	for body in area.get_overlapping_bodies():
		if not body is Infantry:
			continue
			
		if not body.team == team:
			continue
			
		if body.is_dead:
			continue
			
		_units.append(body)
		
	for i in _units:
		var unit: Infantry = i
		unit.rearm()

