extends BaseData
class_name PlayerData

export var player_id :String = ""
export var player_name : String = ""
export var player_color : Color

func from_dictionary(data : Dictionary):
	.from_dictionary(data)
	
	player_id = data["player_id"]
	player_name = data["player_name"]
	player_color = data["player_color"]
	
func to_dictionary() -> Dictionary:
	var data : Dictionary = .to_dictionary()
	data["player_id"] = player_id
	data["player_name"] = player_name
	data["player_color"] = player_color
	return data
	
