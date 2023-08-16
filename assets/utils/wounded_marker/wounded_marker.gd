extends Sprite3D
class_name WoundedMarker

export var expire_time :float = 35
export var revive_time :float = 15

var wounded_unit :Infantry

var _reviver_unit :Infantry = null
onready var _viewport = $Viewport
onready var _wounded_marker_ui = $Viewport/wounded_marker_ui
onready var _revive_area = $revive_area
onready var _revive_timer = $revive_timer
onready var _expired_time = $expired_time

func _ready():
	set_as_toplevel(true)
	visible = false
	texture = _viewport.get_texture()
	_revive_area.set_deferred("monitoring", false)
	
func _process(_delta):
	_check_reviver()
	_reviving()
	
	_wounded_marker_ui.reviving(_revive_timer.time_left, _revive_timer.wait_time)
	translation = wounded_unit.global_transform.origin + Vector3(0,0.5,0)
	
func _reviving():
	var _is_valid_revivier :bool = is_instance_valid(_reviver_unit)
	var _is_revive_timer_stopped :bool = _revive_timer.is_stopped()
	
	if not _is_valid_revivier:
		if not _is_revive_timer_stopped:
			_revive_timer.stop()
			_wounded_marker_ui.hide_reviving_progress()
		return
		
	if _is_revive_timer_stopped:
		_revive_timer.wait_time = revive_time
		_revive_timer.start()
		_wounded_marker_ui.show_reviving_progress()
		
func _check_reviver():
	_reviver_unit = null
	
	if _expired_time.is_stopped():
		return
	
	if not _revive_area.monitoring:
		return
	
	for body in _revive_area.get_overlapping_bodies():
		if not body is BaseUnit:
			continue
			
		var valid_params :Array = [
			body != wounded_unit,
			body is Infantry,
			body.team == wounded_unit.team,
			#not body.is_bot,
			not body.is_dead,
		]
		
		if valid_params.has(false):
			continue
			
		_reviver_unit = body
		return
		
func show_wounded():
	_is_wounded(true)
	_wounded_marker_ui.show_wounded(expire_time)
	_expired_time.wait_time = expire_time
	_expired_time.start()
	
func hide_wounded():
	_is_wounded(false)
	_expired_time.stop()
	
func _is_wounded(val :bool):
	visible = val
	set_process(val)
	_revive_area.set_deferred("monitoring", val)
	
func _revive():
	# call rpc sync reset
	if is_instance_valid(_reviver_unit):
		if _reviver_unit.is_master():
			wounded_unit.revive()
	
	_reviver_unit = null
	_wounded_marker_ui.hide_reviving_progress()
	
func _on_revive_timer_timeout():
	hide_wounded()
	_revive()
	
func _on_expired_time_timeout():
	_is_wounded(false)
	
	_reviver_unit = null
	_wounded_marker_ui.hide_reviving_progress()
	_revive_timer.stop()








