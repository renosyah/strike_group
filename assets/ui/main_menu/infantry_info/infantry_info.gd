extends MarginContainer

signal pressed

onready var panel_2 = $HBoxContainer/MarginContainer/Panel2
onready var unit_name = $HBoxContainer/MarginContainer/HBoxContainer/unit_name
onready var pivot_point :Vector2 = (rect_size / 2)

var data :InfantryData
var unit :BaseUnit

func _ready():
	unit_name.text = "%s" % data.entity_name
	set_selected(false)

func set_selected(val :bool):
	panel_2.visible = val
	
func is_selected() -> bool:
	return panel_2.visible

func _on_Button_pressed():
	emit_signal("pressed")
