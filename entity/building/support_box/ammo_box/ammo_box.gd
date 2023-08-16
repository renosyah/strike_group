extends BaseBuilding

onready var ammo_item = $ammo_item

func _ready():
	ammo_item.is_master = is_master()
	
remotesync func _finish_building():
	._finish_building()
	ammo_item.team = team
	ammo_item.use(true)
