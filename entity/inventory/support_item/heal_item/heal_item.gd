extends SupportItem

const heal_sounds = [
	preload("res://assets/sounds/support_item/heal_1.wav"),
	preload("res://assets/sounds/support_item/heal_2.wav"),
	preload("res://assets/sounds/support_item/heal_3.wav")
]

onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var healing_timer = $healing_timer
onready var mesh_instance_3 = $MeshInstance3
onready var area = $area
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
	
	if not is_master:
		return
		
	if _enable:
		healing_timer.start()
		
	else:
		healing_timer.stop()
		
	_enable_detection(_enable)
	
func get_max_cooldown() -> float:
	return healing_timer.wait_time
	
func cooldown_remain() -> float:
	return healing_timer.time_left
	
	
func _on_healing_timer_timeout():
	if is_master:
		_heal_unit_in_area()
		
	audio_stream_player_3d.stream = heal_sounds[rand_range(0, heal_sounds.size())]
	audio_stream_player_3d.play()
	
	healing_timer.start()
	
func _heal_unit_in_area():
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
		unit.heal(int(unit.max_hp * 0.10))
	




