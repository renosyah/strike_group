extends Control

signal exit_scene

onready var player_name = $CanvasLayer/Control/MarginContainer3/SafeArea/HBoxContainer/MarginContainer4/MarginContainer3/player_name
onready var squad_info_holder = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer5/squad_info_holder
onready var equipment_setting = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer/equipment_setting
onready var tween = $Tween

func _ready():
	equipment_setting.visible = false
	player_name.text = Global.player.player_name
	
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_player_connected")
	NetworkLobbyManager.connect("on_client_player_connected", self, "_on_player_connected")
	
func add_infantry_info(data :InfantryData, unit :BaseUnit, _cam_default_pos :Position3D, _cam_pos :Position3D, _camera :Camera):
	var info = preload("res://assets/ui/main_menu/infantry_info/infantry_info.tscn").instance()
	info.data = data
	info.unit = unit
	info.connect("pressed", self, "on_switch_infantry", [info, data, unit,_cam_default_pos, _cam_pos, _camera])
	squad_info_holder.add_child(info)
	
func on_switch_infantry(info, data :InfantryData, unit :BaseUnit, _cam_default_pos :Position3D, _cam_pos :Position3D, _camera :Camera):
	for _info in squad_info_holder.get_children():
		if _info.is_selected() and _info != info:
			_info.set_selected(false)
		
	info.set_selected(not info.is_selected())
	var is_selected :bool = info.is_selected()
	
	equipment_setting.display(is_selected, data, unit)
	if not is_selected:
		yield(equipment_setting, "display")
		
	if is_selected:
		tween.interpolate_property(_camera, "translation", _camera.translation, _cam_pos.global_transform.origin, 0.6)
		tween.interpolate_property(_camera, "rotation_degrees", _camera.rotation_degrees, _cam_pos.rotation_degrees, 0.6)
		
	else:
		tween.interpolate_property(_camera, "translation", _camera.translation, _cam_default_pos.global_transform.origin, 0.4)
		tween.interpolate_property(_camera, "rotation_degrees", _camera.rotation_degrees, _cam_default_pos.rotation_degrees, 0.4)
		
	tween.start()
		
		
func _on_battle_pressed():
	NetworkLobbyManager.player_name = Global.player.player_name
	NetworkLobbyManager.configuration = NetworkServer.new()
	NetworkLobbyManager.player_extra_data = {
		"units" : Global.player_units_to_dict(Global.player_units),
		"team" : 1
	}
	NetworkLobbyManager.init_lobby()

func _on_player_connected():
	emit_signal("exit_scene")
	Global.change_scene("res://gameplay/mp/host/gameplay.tscn", false, 1)
