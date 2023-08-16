extends InventoryData
class_name GearData

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	return data
	
func spawn_gear(parent :Node) -> Gear:
	var gear :Gear = load(scene_path).instance()
	gear.player_id = player_id
	gear.name = node_name
	gear.icon = load(entity_icon)
	gear.set_network_master(network_id)
	parent.add_child(gear)
	gear.item_name = item_name
	gear.translation = position
	return gear
	
