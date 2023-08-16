extends BaseData
class_name InfantryData

export var player_id :String

export var entity_name :String
export var entity_icon :String
export var description :String

export var node_name :String
export var network_id :int
export var scene_path :String
export var position :Vector3

export var level :int
export var base_attack_damage :int
export var base_max_hp :int

export var base_xp :int
export var current_xp :int
export var max_xp_cap :int

export var team :int
export var color_coat:Color

var weapon :WeaponData
var inventories :Array
var gears :Array

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	player_id = data["player_id"]
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	description = data["description"]
	
	node_name = data["node_name"]
	network_id = data["network_id"]
	scene_path = data["scene_path"]
	position = data["position"]
	
	level = data["level"]
	base_attack_damage = data["base_attack_damage"]
	base_max_hp = data["base_max_hp"]
	
	base_xp = data["base_xp"]
	current_xp = data["current_xp"]
	max_xp_cap = data["max_xp_cap"]
	
	team = data["team"]
	color_coat = data["color_coat"]
	
	if data.has("weapon"):
		weapon = WeaponData.new()
		weapon.from_dictionary(data["weapon"])
		weapon.network_id = network_id
	
	inventories = []
	for i in data["inventories"]:
		var item :InventoryData = InventoryData.new()
		item.from_dictionary(i)
		item.network_id = network_id
		inventories.append(item)
		
	gears = []
	for i in data["gears"]:
		var item :GearData = GearData.new()
		item.from_dictionary(i)
		item.network_id = network_id
		gears.append(item)
	
func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["player_id"] = player_id
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	data["description"] = description
	
	data["node_name"] = node_name
	data["network_id"] = network_id
	data["scene_path"] = scene_path
	data["position"] = position
	
	data["level"] = level
	data["base_attack_damage"] = base_attack_damage
	data["base_max_hp"] =base_max_hp
	
	data["base_xp"] = base_xp
	data["current_xp"] = current_xp
	data["max_xp_cap"] = max_xp_cap
	
	data["team"] = team
	data["color_coat"] = color_coat
	
	if weapon:
		weapon.network_id = network_id
		data["weapon"] = weapon.to_dictionary()
	
	data["inventories"] = []
	for i in inventories:
		var item :InventoryData = i
		item.network_id = network_id
		data["inventories"].append(item.to_dictionary())
		
	data["gears"] = []
	for i in gears:
		var item :GearData = i
		item.network_id = network_id
		data["gears"].append(item.to_dictionary())
		
	return data
	
func spawn_infantry(parent :Node) -> Infantry:
	var infantry :Infantry = load(scene_path).instance()
	infantry.player_id = player_id
	infantry.name = node_name
	infantry.set_network_master(network_id)
	infantry.attack_damage = LevelSystem.get_value(level, base_attack_damage)
	infantry.max_hp = LevelSystem.get_value(level, base_max_hp)
	infantry.hp = infantry.max_hp
	infantry.team = team
	infantry.color_coat = color_coat
	infantry.enable_network = true
	parent.add_child(infantry)
	infantry.translation = position
	
	if weapon:
		var primary_weapon :Weapon = weapon.spawn_weapon(infantry)
		infantry.equip_weapon(primary_weapon, false)
	
	for i in inventories:
		var item :InventoryData = i
		var inventory :Inventory = item.spawn_inventory(infantry)
		inventory.translation = Vector3.ZERO
		inventory.visible = false
		infantry.inventories.append(inventory)
		
	for i in gears:
		var item :GearData = i
		infantry.equip_gear(item.spawn_gear(infantry), false)
		
	return infantry
	







