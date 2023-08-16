extends InventoryData
class_name WeaponData

export var is_unlimited :bool
export var mods :Array

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	is_unlimited = data["is_unlimited"]
	
	mods = []
	for i in data["mods"]:
		var mod :WeaponModData = WeaponModData.new()
		mod.from_dictionary(i)
		mods.append(mod)
	
func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["is_unlimited"] = is_unlimited
	
	data["mods"] = []
	for i in mods:
		var mod :WeaponModData = i
		data["mods"].append(mod.to_dictionary())
	
	return data
	
func spawn_weapon(parent :Node) -> Weapon:
	var weapon :Weapon = load(scene_path).instance()
	weapon.player_id = player_id
	weapon.name = node_name
	weapon.icon = load(entity_icon)
	weapon.set_network_master(network_id)
	parent.add_child(weapon)
	weapon.item_name = item_name
	weapon.translation = position
	weapon.is_unlimited = is_unlimited
	
	for i in mods:
		var mod :WeaponModData = i
		var weapon_mod :WeaponMod = mod.spawn_weapon_mod(weapon)
		weapon.add_weapon_mod(weapon_mod)
		
	return weapon
	
