extends Button
class_name InventoryInfo

var item :Inventory

onready var item_icon = $MarginContainer/HBoxContainer/icon
onready var panel_2 = $MarginContainer/Panel2
onready var item_name = $MarginContainer/HBoxContainer/VBoxContainer/item_name
onready var progress = $MarginContainer/HBoxContainer/VBoxContainer/progress

func _ready():
	item_icon.texture = item.icon
	item_name.text = item.item_name
	
func set_selected(val :bool):
	panel_2.visible = val
	progress.visible = val
	
	if item is SupportItem:
		progress.max_value = item.get_max_cooldown()
		progress.value = item.cooldown_remain()
		
func _process(_delta):
	if not item is SupportItem:
		set_process(false)
		return
		
	progress.max_value = item.get_max_cooldown()
	progress.value = item.cooldown_remain()
