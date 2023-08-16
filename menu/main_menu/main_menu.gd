extends Node

onready var camera = $Camera
onready var unit_positions :Array = $units.get_children()
onready var center_pos = $center.global_transform.origin
onready var cam_default_pos :Position3D = $Position3D
onready var ui = $ui
onready var tween = $Tween

func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	spawn_unit()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	get_tree().quit()
	
func spawn_unit():
	for i in range(Global.player_units.size()):
		var unit :InfantryData = Global.player_units[i]
		unit.position = unit_positions[i].global_transform.origin
		unit_spawned(unit, unit.spawn_infantry(self))
		
func unit_spawned(data :InfantryData, unit :Infantry):
	unit.offline_mode = true
	
	var cam_pos :Position3D = Position3D.new()
	add_child(cam_pos)
	
	unit.face_direction = unit.translation.direction_to(cam_pos.global_transform.origin)
	
	cam_pos.translation = unit.translation + unit.transform.basis.z * 3
	cam_pos.look_at(unit.translation - Vector3(0, 1, 0), Vector3.UP)
	cam_pos.translation.y -= 1.5
	
	ui.add_infantry_info(data, unit,cam_default_pos, cam_pos, $Camera)
	
func _on_ui_exit_scene():
	tween.interpolate_property(camera, "translation", camera.translation, camera.translation - Vector3(0,2,0), 0.6)
	tween.start()















