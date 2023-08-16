extends BaseGameplay
class_name BaseShowcaseMp

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_player_squad()
	setup_map()
	setup_camera()
	setup_sound()
	setup_ui()
	
################################################################
# network connection watcher
# for both client and host
func all_player_ready():
	.all_player_ready()
	
	Global.dismiss_transition()
	
################################################################
var player_squad_units :Dictionary
var player_squad :SquadFormation
var player_units_highlight :Dictionary = {}

func setup_player_squad():
	player_squad = preload("res://assets/utils/squad_formation/squad_formation.tscn").instance()
	add_child(player_squad)
	
	player_squad_units = NetworkLobbyManager.player_extra_data["units"]
	
################################################################
# cameras
var _camera :FixCamera

func setup_camera():
	_camera = preload("res://assets/utils/fix_camera/fix_camera.tscn").instance()
	add_child(_camera)
	
################################################################
# sounds
var _sound :AudioStreamPlayer

func setup_sound():
	_sound = AudioStreamPlayer.new()
	add_child(_sound)
	
################################################################
# map
var _map :BaseMap

func setup_map():
	_map = preload("res://map/spring_island/spring_map.tscn").instance()
	_map.connect("on_generate_map_completed", self, "on_generate_map_completed")
	_map.name = "map"
	_map.map_size = 200
	add_child(_map)
	
	var _water :Water = preload("res://map/water/water.tscn").instance()
	_water.name = "water"
	_water.map_size = 200
	add_child(_water)
	
	# server generate map
	# to create server map data
	if is_server():
		randomize()
		NetworkLobbyManager.argument["map_seed"] = rand_range(-100, 100)
		
	_map.map_seed = NetworkLobbyManager.argument["map_seed"]
	_map.generate_map()
	
func on_generate_map_completed():
	if is_server():
		NetworkLobbyManager.argument["map_entities"] = create_map_entities()
		NetworkLobbyManager.set_host_ready()
		
	spawn_map_entity()
	
func create_map_entities() -> Array:
	var _map_entities :Array = []
	for pos in _map.spawn_positions:
		_map_entities.append({
			"mesh": MapEntity.get_random_mesh(),
			"pos": pos,
			"rot": rand_range(0, 360)
		})
		
	return _map_entities
	
func spawn_map_entity():
	var map_entities :Array = NetworkLobbyManager.argument["map_entities"]
	for data in map_entities:
		var entity :MapEntity = preload("res://entity/map_entity/map_entity.tscn").instance()
		entity.mesh = load(data["mesh"])
		_map.add_child(entity)
		entity.translation = data["pos"]
		entity.rotation_degrees.y = data["rot"]
		
	NetworkLobbyManager.set_ready()
	
################################################################
# ui
var _ui :BaseGameplayUi

func setup_ui():
	_ui = preload("res://gameplay/showcase/ui/ui.tscn").instance()
	add_child(_ui)
	
	_ui.connect("switch_item", self, "on_switch_item")
	_ui.connect("switch_unit", self ,"on_switch_unit")
	_ui.connect("switch_weapon", self ,"on_switch_weapon")
	_ui.connect("cycle_weapon", self, "on_cycle_weapon")
	_ui.connect("reload", self, "on_reload")
	_ui.connect("retreat", self, "on_retreat")
	_ui.connect("main_menu", self, "on_exit_game_session")
	
################################################################
# ui signals handler
func on_switch_unit(unit_target :BaseUnit):
	for i in player_squad.squad_members:
		var unit :Infantry = i
		unit.is_bot = true
		
	player_squad.squad_leader = unit_target
	player_squad.squad_leader.speed_modifier = 1
	
	_camera.rotation = player_squad.squad_leader.rotation
	
	highlight_selected_unit(unit_target)
	_ui.refresh_inventory_info(player_squad.squad_leader)
	
func on_switch_item(item :SupportItem):
	if not is_instance_valid(player_squad.squad_leader):
		return
		
	player_squad.squad_leader.equip_item(item)
	
func on_switch_weapon(weapon :Weapon):
	if not is_instance_valid(player_squad.squad_leader):
		return
		
	player_squad.squad_leader.equip_weapon(weapon)
	
func on_reload():
	if not is_instance_valid(player_squad):
		return
		
	if not is_instance_valid(player_squad.squad_leader):
		return
		
	player_squad.squad_leader.reload_weapon()
	
func on_cycle_weapon():
	if not is_instance_valid(player_squad):
		return
		
	for i in player_squad.squad_members:
		var unit :Infantry = i
		if unit != player_squad.squad_leader:
			unit.switch_weapon()
	
	yield(get_tree(),"idle_frame")
	_ui.refresh_inventory_info(player_squad.squad_leader)
	
func on_retreat():
	if not is_instance_valid(player_squad):
		return
		
	player_squad.order_retreat()
	
################################################################
func on_infantry_spawned(_data :InfantryData, _infantry : Infantry):
	.on_infantry_spawned(_data, _infantry)
	
	if player_squad_units.has(_data.player_id):
		_ui.add_infantry_info(_data, _infantry)
		
		player_squad.squad_members.append(_infantry)
		player_squad.create_squad()
		
		player_squad.retreat_point = _data.position
		
		var wounded_marker :WoundedMarker = preload("res://assets/utils/wounded_marker/wounded_marker.tscn").instance()
		_infantry.add_child(wounded_marker)
		wounded_marker.translation.y = 0.5
		
		var highlight = preload("res://assets/utils/highlight/highlight.tscn").instance()
		_infantry.add_child(highlight)
		highlight.translation.y -= 0.7
		
		player_units_highlight[_infantry] = highlight
		
		_infantry.connect("dead", self, "_on_player_infantry_dead", [_data, wounded_marker])
		_infantry.connect("reset", self, "_on_player_infantry_reset", [_data, wounded_marker])
		
		on_switch_unit(player_squad.squad_leader)
		
################################################################
# player unit signals handler
func _on_player_infantry_dead(_unit :BaseUnit, _from :Vector3, _by :String, _data :InfantryData, wounded_marker :WoundedMarker):
	if _unit == player_squad.squad_leader:
		_ui.refresh_inventory_info(player_squad.squad_leader)
		
	wounded_marker.expire_time = 45
	wounded_marker.show_wounded()
	
func _on_player_infantry_reset(_unit :BaseUnit, _data :InfantryData, wounded_marker :WoundedMarker):
	if _unit == player_squad.squad_leader:
		_unit.is_bot = false
		_ui.refresh_inventory_info(player_squad.squad_leader)
		
	wounded_marker.hide_wounded()
	
func highlight_selected_unit(_unit :BaseUnit):
	for key in player_units_highlight.keys():
		player_units_highlight[key].highlight(false)
	
	if player_units_highlight.has(_unit):
		player_units_highlight[_unit].highlight(true)
	
################################################################
# unit signals handler
func on_unit_take_damage(_unit :BaseUnit, _damage :int, _from :Vector3, _by :String, _data :InfantryData):
	.on_unit_take_damage(_unit, _damage, _from, _by, _data)
	
	if _unit == player_squad.squad_leader and not _by.empty():
		_ui.show_damage(_from, _camera.rotation_degrees.y)
	
	if _unit == player_squad.squad_leader.target:
		_ui.update_player_target_info(_data, _unit)
	
func on_unit_dead(_unit :BaseUnit, _from :Vector3, _by :String, _data :InfantryData):
	.on_unit_dead(_unit, _from, _by, _data)
	
func on_unit_reset(_unit :BaseUnit, _data :InfantryData):
	.on_unit_reset(_unit, _data)
	
	
################################################################
# proccess
func _process(delta):
	if not is_instance_valid(player_squad):
		return
		
	if not is_instance_valid(player_squad.squad_leader):
		return
		
	var camera :Camera = _camera.get_camera()
	var selected_unit :Infantry = player_squad.squad_leader
	var selected_unit_is_bot :bool = selected_unit.is_bot
	var unit_pos :Vector3 =selected_unit.global_transform.origin
	
	var _input :Vector3 = _ui.get_joystick_output(_camera.global_transform.basis)
	
	if selected_unit_is_bot and _input.length() > 0 and not player_squad.is_retreating():
		selected_unit.is_bot = false
		
	if not selected_unit_is_bot:
		selected_unit.move_direction = _input
		selected_unit.face_direction = _input
	
	_camera.translation = selected_unit.translation
	_camera.rotation.y = lerp_angle(_camera.rotation.y, selected_unit.rotation.y , 1 * delta)
	
	_ui.update_unit_weapon_info(selected_unit)
	_ui.set_crosshair_position(camera.unproject_position(selected_unit.aim_position))
	_ui.show_joystick(not selected_unit.is_dead)
	_ui.enable_retreat_button(player_squad.can_retreat())
	_ui.update_compass(_camera.rotation_degrees.y, unit_pos, _map.point_spawn_positions[0])















