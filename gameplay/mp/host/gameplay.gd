extends BaseGameplayMp

var max_squad_number :int = 4

var bot_squads :Dictionary = {}
var team_spawn_position :Dictionary = {}
var bot_rogue_ids :Array = []

var rogue_bots :Array = []
var respawn_timer :Dictionary = {}

onready var timer = $Timer

func _ready():
	timer.start()

func all_player_ready():
	.all_player_ready()
	
	var spawn_pos = _map.base_spawn_positions.slice(0, 3)
	spawn_pos.shuffle()
	
	for i in 4:
		team_spawn_position[i] = spawn_pos[i]
		
	var units :Array = []
	var squad_spawn_index :int = 0
	var bot_count = 4
	
	for p in NetworkLobbyManager.get_players():
		var player :NetworkPlayer = p
		
		var unit_index :int = 0
		for i in player.extra["units"]:
			var unit :InfantryData = InfantryData.new()
			unit.from_dictionary(i)
			unit.position = team_spawn_position[squad_spawn_index] + Vector3(unit_index, 5, 0)
			unit.node_name = "player_%s_%s" % [unit.player_id, player.player_network_unique_id]
			unit.network_id = player.player_network_unique_id
			unit.team = player.extra["team"]
			units.append(unit)
			unit_index += 1
			
		bot_count -= 1
		squad_spawn_index += 1
		
	var bot_weapons = Global.get_files("res://data/inventory/weapon/primary/")
	var bot_headgear = Global.get_files("res://data/inventory/gear/head_gear/list/")
	var bot_face_gear = Global.get_files("res://data/inventory/gear/facewear/list/")
	var bot_armor = Global.get_files("res://data/inventory/gear/body_armor/list/")
	var bot_backpack = Global.get_files("res://data/inventory/gear/backpack/list/")
	
	var bot_team = 2
	
	for _pos in range(bot_count):
		bot_weapons.shuffle()
		
		var bot_squad_id :String = "squad_bot_%s" % GDUUID.v4()
		var squad_spawn_position :Vector3 = team_spawn_position[squad_spawn_index]

		var bot_squad_formation = preload("res://assets/utils/squad_formation/squad_formation.tscn").instance()
		bot_squad_formation.space = 4
		bot_squad_formation.force_follow = false
		add_child(bot_squad_formation)
		bot_squads[bot_squad_id] = bot_squad_formation

		var color = Color(randf(), randf(), randf(), 1.0)

		for i in max_squad_number:
			var _weapon = bot_weapons[i].duplicate()
			_weapon.node_name = "p_weapon_bot_%s_%s" % [bot_squad_id, i]
			_weapon.player_id = bot_squad_id
			_weapon.is_unlimited = true
			
			var _gears :Array = []
			
			var _head :GearData = bot_headgear[rand_range(0, bot_headgear.size())].duplicate()
			_head.node_name = "gear_head_%s_%s" % [bot_squad_id, i]
			_head.player_id = bot_squad_id
			_gears.append(_head)
			
			var _face :GearData = bot_face_gear[rand_range(0, bot_face_gear.size())].duplicate()
			_face.node_name = "gear_face_%s_%s" % [bot_squad_id, i]
			_face.player_id = bot_squad_id
			_gears.append(_face)
			
			var _armor :GearData = bot_armor[rand_range(0, bot_armor.size())].duplicate()
			_armor.node_name = "gear_armor_%s_%s" % [bot_squad_id, i]
			_armor.player_id = bot_squad_id
			_gears.append(_armor)
			
			var _bag :GearData = bot_backpack[rand_range(0, bot_backpack.size())].duplicate()
			_bag.node_name = "gear_bag_%s_%s" % [bot_squad_id, i]
			_bag.player_id = bot_squad_id
			_gears.append(_bag)
			
			var bot = preload("res://data/infantry/list/riflemen.tres").duplicate()
			bot.player_id = bot_squad_id
			bot.entity_name = "%s (Bot)" % RandomNameGenerator.generate()
			bot.node_name = "bot_%s_%s" % [bot_squad_id, i]
			bot.position = squad_spawn_position + Vector3(i, 5, 0)
			bot.network_id = 1
			bot.team = bot_team
			bot.color_coat = color
			bot.weapon = _weapon
			bot.inventories = []
			bot.gears = _gears
			units.append(bot)
			
		bot_team += 1
		squad_spawn_index += 1
	
	.spawn_infantries(units)
	
	
func on_infantry_spawned(_data :InfantryData, _infantry : Infantry):
	.on_infantry_spawned(_data, _infantry)
	
	# control bot squad
	if bot_squads.has(_data.player_id):
		bot_squads[_data.player_id].squad_members.append(_infantry)
		bot_squads[_data.player_id].create_squad()
		bot_squads[_data.player_id].squad_leader.is_bot = true
		
	# control rogue bot
	if bot_rogue_ids.has(_data.player_id):
		_infantry.is_bot = true
		rogue_bots.append(_infantry)
		
func on_unit_dead(_unit :BaseUnit,_from :Vector3, _by :String, _data :InfantryData):
	.on_unit_dead(_unit, _from, _by, _data)
	
	remove_respawn_time(_unit)
	create_respawn_timer(_unit, _data)
	
func on_unit_reset(_unit :BaseUnit, _data :InfantryData):
	.on_unit_reset(_unit, _data)
	
	remove_respawn_time(_unit)
	
	
func _on_respawn_timer_timeout(_unit :BaseUnit, _data :InfantryData):
	var spawn_pos :Vector3 = get_random_point_position()
	
	if  team_spawn_position.has(_unit.team):
		spawn_pos = team_spawn_position[_unit.team]
		
	.respawn(_unit, spawn_pos + Vector3(0, 10, 0))
	
	
func _on_Timer_timeout():
	timer.start()
	
	for bot in rogue_bots:
		if not bot.is_moving:
			if not is_instance_valid(bot.target):
				bot.is_moving = true
				bot.move_to = get_random_position()
				bot.speed_modifier = 1
	
	for key in bot_squads.keys():
		var squad :SquadFormation = bot_squads[key]
		if is_instance_valid(squad.squad_leader):
			if not squad.squad_leader.is_moving:
				if not is_instance_valid(squad.squad_leader.target):
					squad.squad_leader.is_moving = true
					squad.squad_leader.move_to = get_random_position()
					squad.squad_leader.speed_modifier = 1
		
func get_random_position() -> Vector3:
	return _map.spawn_positions[rand_range(0, _map.spawn_positions.size())]

func get_random_point_position() -> Vector3:
	return _map.point_spawn_positions[rand_range(0, _map.point_spawn_positions.size())]

func create_respawn_timer(_unit :BaseUnit, _data :InfantryData):
	var new_timer :Timer = Timer.new()
	new_timer.wait_time = 60
	new_timer.one_shot = true
	new_timer.autostart = false
	new_timer.connect("timeout", self, "_on_respawn_timer_timeout", [_unit, _data])
	add_child(new_timer)
	new_timer.start()
	
	respawn_timer[_unit] = new_timer
	
func remove_respawn_time(_unit :BaseUnit):
	if respawn_timer.has(_unit):
		var prev_timer :Timer = respawn_timer[_unit]
		prev_timer.queue_free()
		respawn_timer.erase(_unit)













