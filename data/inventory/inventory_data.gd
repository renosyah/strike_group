extends BaseData
class_name InventoryData

enum typeInventory { weapon, weapon_mod, support_item, gear}

export(typeInventory) var type

export var player_id :String
export var item_name :String

export var entity_name :String
export var entity_icon :String
export var description :String

export var node_name :String
export var network_id :int
export var scene_path :String
export var position :Vector3


func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	type = data["type"]
	
	player_id = data["player_id"]
	item_name = data["item_name"]
	
	entity_name = data["entity_name"]
	entity_icon = data["entity_icon"]
	description = data["description"]
	
	node_name = data["node_name"]
	network_id = data["network_id"]
	scene_path = data["scene_path"]
	position = data["position"]

func to_dictionary() -> Dictionary :
	var data = .to_dictionary()
	
	data["type"] = type
	
	data["player_id"] = player_id
	data["item_name"] = item_name
	
	data["entity_name"] = entity_name
	data["entity_icon"] = entity_icon
	data["description"] = description
	
	data["node_name"] = node_name
	data["network_id"] = network_id
	data["scene_path"] = scene_path
	data["position"] = position
	
	return data
	
func spawn_inventory(parent :Node) -> Inventory:
	var inventory :Inventory = load(scene_path).instance()
	inventory.player_id = player_id
	inventory.name = node_name
	inventory.icon = load(entity_icon)
	inventory.set_network_master(network_id)
	parent.add_child(inventory)
	inventory.item_name = item_name
	inventory.translation = position
	return inventory
	







