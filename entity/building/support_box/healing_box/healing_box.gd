extends BaseBuilding

onready var heal_item = $heal_item

func _ready():
	heal_item.is_master = is_master()
	
remotesync func _finish_building():
	._finish_building()
	heal_item.team = team
	heal_item.use(true)















