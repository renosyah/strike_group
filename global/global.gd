extends Node

################################################################
# versioning
onready var game_version :int = 1

################################################################
# sound
const is_dekstop =  ["Server", "Windows", "WinRT", "X11"]
onready var sound_amplified :float = 1.0 if OS.get_name() in is_dekstop else 1.0

################################################################
func _ready():
	setup_transition()
	setup_player()
	load_player_inventories()
	load_player_units()
	
################################################################
var transition :SceneTransision

func setup_transition():
	transition = preload("res://assets/ui/loading/scene_transition.tscn").instance()
	add_child(transition)

func change_scene(scene :String, auto_dismiss :bool = true, index :int = 0):
	transition.index = index
	transition.change_scene(scene, auto_dismiss)

func dismiss_transition():
	transition.dismiss()

################################################################
# player
const player_save_file = "player.data"
onready var player :PlayerData = PlayerData.new()

func setup_player():
	var player_data = SaveLoad.load_save(player_save_file)
	if player_data == null:
		player.player_id = "player_%s" % GDUUID.v4()
		player.player_name = RandomNameGenerator.generate()
		player.player_color = Color(randf(), randf(), randf(), 1)
		player.save_data(player_save_file)
		return
		
	player.load_data(player_save_file)
	
################################################################
# player squad
const player_save_units_file = "player_units.data"
var player_units :Array = []

func load_player_units():
	var datas = SaveLoad.load_save(player_save_units_file)
	if datas == null:
		player_units = create_starter_squad()
		save_player_units()
		return
		
	datas = SaveLoad.load_save(player_save_units_file)
	player_units = player_units_from_dict(datas)
	
func save_player_units():
	SaveLoad.save(player_save_units_file, player_units_to_dict(player_units))
	
func player_units_to_dict(_player_units :Array) -> Array:
	var units :Array = []
	for i in _player_units:
		var unit :InfantryData = i
		units.append(unit.to_dictionary())
		
	return units
	
func player_units_from_dict(_player_units :Array) -> Array:
	var units :Array = []
	for i in _player_units:
		var unit :InfantryData = InfantryData.new()
		unit.from_dictionary(i)
		units.append(unit)
		
	return units
	
	
func create_starter_squad() -> Array:
	var units :Array = []
	var ranks :Array = ["Sgt.","Cpl.","Pvt.","Pvt."]
	
	var index :int = 0
	for rank in ranks:
		var unit = preload("res://data/infantry/list/riflemen.tres").duplicate()
		unit.player_id = "unit_%s_%s_%s" % [player.player_id, GDUUID.v4(),index]
		unit.entity_name = "%s %s" % [rank, RandomNameGenerator.generate()]
		unit.node_name = "riflement_%s" % unit.player_id
		unit.position = Vector3.ZERO
		unit.network_id = Network.PLAYER_HOST_ID
		unit.team = 1
		unit.color_coat = player.player_color
		
		unit.inventories = []
		unit.gears = []
		
		units.append(unit)
		index += 1
		
	return units
	
################################################################
# player weapons
const player_save_inventories_file = "player_inventories.data"
var player_inventories :Array = []

func load_player_inventories():
	var datas = SaveLoad.load_save(player_save_inventories_file)
	if datas == null:
		player_inventories = create_starter_inventories()
		save_player_inventories()
		return
		
	datas = SaveLoad.load_save(player_save_inventories_file)
	player_inventories = player_inventories_from_dict(datas)
	
func save_player_inventories():
	SaveLoad.save(player_save_inventories_file, player_inventories_to_dict(player_inventories))
	
func player_inventories_to_dict(_inventories :Array) -> Array:
	var inventories :Array = []
	for i in _inventories:
		var item :InventoryData = i
		inventories.append(item.to_dictionary())
		
	return inventories
	
func player_inventories_from_dict(_inventories :Array) -> Array:
	var inventories :Array = []
	for i in _inventories:
		match (i["type"]):
			InventoryData.typeInventory.weapon:
				var item :WeaponData = WeaponData.new()
				item.from_dictionary(i)
				inventories.append(item)
				
			InventoryData.typeInventory.weapon_mod:
				var item :WeaponModData = WeaponModData.new()
				item.from_dictionary(i)
				inventories.append(item)
				
			InventoryData.typeInventory.support_item:
				var item :SupportItemData = SupportItemData.new()
				item.from_dictionary(i)
				inventories.append(item)
				
			InventoryData.typeInventory.gear:
				var item :GearData = GearData.new()
				item.from_dictionary(i)
				inventories.append(item)
				
	return inventories
	
func create_starter_inventories() -> Array:
	var items :Array = get_all_inventories()
	items.shuffle()
	
	var inventories :Array = []
	for i in 8:
		var item = items[i].duplicate()
		item.node_name = "item_%s_%s" % [GDUUID.v4(), player.player_id]
		inventories.append(item)
		
	return inventories
	
func get_all_inventories() -> Array:
	var paths = [
		"res://data/inventory/gear/backpack/list/",
		"res://data/inventory/gear/body_armor/list/",
		"res://data/inventory/gear/facewear/list/",
		"res://data/inventory/gear/head_gear/list/",
		
		"res://data/inventory/support_item/list/",
		
		"res://data/inventory/weapon/primary/",
		"res://data/inventory/weapon/secondary/",
		"res://data/inventory/weapon/special/",
		
		"res://data/inventory/weapon_mod/barel/",
		"res://data/inventory/weapon_mod/grip/",
		"res://data/inventory/weapon_mod/mag/",
		"res://data/inventory/weapon_mod/receiver/",
		"res://data/inventory/weapon_mod/scope/"
	]
	var files = []
	for path in paths:
		files.append_array(get_files(path))
		
	return files
	
func get_files(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			var full_path :String = "%s/%s" % [path, file]
			files.append(ResourceLoader.load(full_path).duplicate())
			
	dir.list_dir_end()
	
	return files
################################################################
# setting
signal on_setting_update

var setting_data :SettingData = SettingData.new()
const player_setting_data_file = "player_setting_data.data"

func load_setting():
	var setting = SaveLoad.load_save(player_setting_data_file)
	if setting == null:
		return
		
	setting_data.from_dictionary(setting)
	
func apply_setting_data():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Sfx"), setting_data.is_sfx_mute)
	setting_data.save_data(player_setting_data_file)
	
	emit_signal("on_setting_update")
	


























