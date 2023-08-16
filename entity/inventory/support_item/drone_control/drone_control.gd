extends SupportItem

export var attack_damage :int = 15

onready var cooldown_timer = $cooldown_timer
onready var lifetime_timer = $lifetime_timer
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var position_3d = $Position3D

var _drone :Drone
var _enable_drone :bool
var _drone_deployed :bool

func _ready():
	audio_stream_player_3d.unit_size = 5
	
	_drone = preload("res://entity/unit/drone/drone.tscn").instance()
	_drone.name = name
	_drone.team = 0
	_drone.is_bot = true
	_drone.player_id = player_id
	_drone.attack_damage = attack_damage
	_drone.connect("dead", self, "_on_drone_dead")
	_drone.set_network_master(get_network_master())
	
	var last_index = get_tree().get_root().get_child_count() - 1
	get_tree().get_root().get_child(last_index).add_child(_drone)
	
	_drone.translation = global_transform.origin + Vector3(25, 25, 25)
	
func queue_free():
	.queue_free()
	
	_drone.queue_free()
	
func use(_enable :bool):
	.use(_enable)
	
	_enable_drone = _enable
	
	if not display_area:
		return
		
	_drone.set_team(team)
	_drone.active = _enable
	
	if _enable_drone:
		if not _drone_deployed:
			cooldown_timer.start()
			
	else:
		cooldown_timer.stop()
	
func _process(_delta):
	if _drone_deployed and is_master:
		_drone.is_moving = true
		_drone.move_to = position_3d.global_transform.origin
		
func _on_cooldown_timer_timeout():
	_drone_deployed = true
	
	if display_area:
		audio_stream_player_3d.stream = preload("res://assets/sounds/support_item/drone_online.wav")
		audio_stream_player_3d.play()
		
	if _drone.is_dead:
		_drone.reset(false)
		
	_drone.translation = global_transform.origin + Vector3(25, 25, 25)
	_drone.set_active(true)
	
	lifetime_timer.start()

func _on_lifetime_timer_timeout():
	_drone_deployed = false
	_drone.destroy()
	
	if _enable_drone:
		cooldown_timer.start()
	
func _on_drone_dead(_unit :BaseUnit, _from :Vector3, _by :String):
	_drone_deployed = false
	
	if _enable_drone:
		cooldown_timer.start()
	
func get_max_cooldown() -> float:
	if _drone_deployed:
		return lifetime_timer.wait_time
		
	return cooldown_timer.wait_time
	
func cooldown_remain() -> float:
	if _drone_deployed:
		return lifetime_timer.time_left
		
	return cooldown_timer.time_left
	





