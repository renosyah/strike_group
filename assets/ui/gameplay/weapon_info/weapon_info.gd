extends Button
class_name WeaponInfo

var weapon :Weapon

onready var item_icon = $MarginContainer/HBoxContainer/icon
onready var panel_2 = $MarginContainer/Panel2
onready var weapon_name = $MarginContainer/HBoxContainer/VBoxContainer/weapon_name
onready var ammo = $MarginContainer/HBoxContainer/VBoxContainer/ammo

func _ready():
	item_icon.texture = weapon.icon
	weapon_name.text = weapon.item_name
	
func set_selected(val :bool):
	panel_2.visible = val
	
func _process(_delta):
	if not is_instance_valid(weapon):
		set_process(false)
		queue_free()
		return
		
	ammo.text = "%s/%s" % [weapon.ammo, weapon.ammo_pool]
