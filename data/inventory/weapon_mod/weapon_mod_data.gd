extends InventoryData
class_name WeaponModData

func spawn_weapon_mod(parent :Node) -> WeaponMod:
	var mod :WeaponMod = load(scene_path).instance()
	mod.player_id = player_id
	mod.name = node_name
	mod.icon = load(entity_icon)
	parent.add_child(mod)
	return mod
