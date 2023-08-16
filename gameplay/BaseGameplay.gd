extends Node
class_name BaseGameplay

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	setup_parents()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	on_exit_game_session()
	
################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_host_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "connection_closed")
	NetworkLobbyManager.connect("all_player_ready", self, "all_player_ready")
	NetworkLobbyManager.connect("on_player_disconnected", self, "on_player_disconnected")
	
func on_player_disconnected(_player_network :NetworkPlayer):
	pass
	
func connection_closed():
	to_main_menu()
	
func on_host_disconnected():
	to_main_menu()
	
func all_player_ready():
	Global.dismiss_transition()
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
func to_main_menu():
	Global.change_scene("res://menu/main_menu/main_menu.tscn")
	
################################################################
# holders
var _infantry_parent :Node

func setup_parents():
	_infantry_parent = Node.new()
	_infantry_parent.name = "infantry_parent"
	add_child(_infantry_parent)
	
################################################################
# infantry spawner
func spawn_infantries(_datas :Array, _parent :Node = _infantry_parent):
	if not is_server():
		return
		
	var _datas_dicts :Array = []
	for i in _datas:
		_datas_dicts.append(i.to_dictionary())
		
	rpc("_spawn_infantries", _datas_dicts, _parent.get_path())
	
remotesync func _spawn_infantries(_datas :Array, _parent_path :NodePath):
	for data in _datas:
		_spawn_infantry(data, _parent_path)
	
func spawn_infantry(_data :InfantryData, _parent :Node = _infantry_parent):
	if not is_server():
		return
		
	rpc("_spawn_infantry", _data.to_dictionary(), _parent.get_path())
	
remotesync func _spawn_infantry(_data :Dictionary, _parent_path :NodePath):
	var _infantry_data :InfantryData = InfantryData .new()
	_infantry_data.from_dictionary(_data)
	
	var _parent = get_node_or_null(_parent_path)
	if not is_instance_valid(_parent):
		return
		
	var _infantry :Infantry = _infantry_data.spawn_infantry(_parent)
	on_infantry_spawned(_infantry_data, _infantry)
	
func on_infantry_spawned(_data :InfantryData, _infantry : Infantry):
	_infantry.connect("take_damage", self, "on_unit_take_damage", [_data])
	_infantry.connect("dead", self, "on_unit_dead", [_data])
	_infantry.connect("reset", self, "on_unit_reset", [_data])
	
################################################################
# unit signals handler
func on_unit_take_damage(_unit :BaseUnit, _damage :int, _from :Vector3, _by :String, _data :InfantryData):
	pass
	
func on_unit_dead(_unit :BaseUnit, _from :Vector3, _by :String, _data :InfantryData):
	pass

func on_unit_reset(_unit :BaseUnit, _data :InfantryData):
	pass
	
################################################################
# respawner
func respawn(_unit :BaseUnit, _position :Vector3):
	if not is_server():
		return
		
	if not _unit.is_dead:
		return
		
	rpc("_respawn", _unit.get_path(), _position)
	
remotesync func _respawn(_node_path :NodePath, _position :Vector3):
	var _unit :BaseUnit = get_node_or_null(_node_path)
	if not is_instance_valid(_unit):
		return
		
	# no need to call rpc sync again
	# because this function
	# is already execute
	# on all peers
	_unit.reset(false)
	_unit.translation = _position
	
################################################################
# utils code
func get_players_positions(players :Array) -> Array:
	var pos :Array = []
	for player in players:
		if player is BaseUnit:
			pos.append(player.global_transform.origin)
			
	return pos
	
func get_avg_position(list_pos :Array, y :float = 0) -> Vector3:
	var pos :Vector3 = Vector3.ZERO
	var pos_len = list_pos.size()
	for i in list_pos:
		pos += i
		
	pos = pos / pos_len
	pos.y = y
	return pos
	
func get_closes(bodies :Array, from :Vector3) -> BaseUnit:
	if bodies.empty():
		return null
		
	var default :BaseUnit = bodies[0]
	for i in bodies:
		var dis_1 = from.distance_squared_to(default.global_transform.origin)
		var dis_2 = from.distance_squared_to(i.global_transform.origin)
		
		if dis_2 < dis_1:
			default = i
		
	return default
	
################################################################
# network utils code
func is_server():
	if not is_network_on():
		return false
		
	if not get_tree().is_network_server():
		return false
		
	return true
	
func is_network_on() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
################################################################


