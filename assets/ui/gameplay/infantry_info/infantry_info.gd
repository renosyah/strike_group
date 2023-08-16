extends Button
class_name InfantryInfo

onready var panel_2 = $MarginContainer/Panel2
onready var panel_3 = $MarginContainer/Panel3
onready var unit_name = $MarginContainer/HBoxContainer/VBoxContainer/unit_name
onready var unit_level = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/MarginContainer/unit_level
onready var hp_bar = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/hp_bar
onready var ammo_bar = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/ammo

func _ready():
	panel_2.visible = false
	panel_3.visible = false
	hp_bar.set_hp_bar_color(Color.green)

func set_selected(val :bool):
	panel_2.visible = val

func set_infantry_info(data :InfantryData, unit :BaseUnit):
	unit_name.text = "%s" % data.entity_name
	unit_level.text = "%s" % data.level
	hp_bar.update_bar(unit.hp, unit.max_hp)
	
	unit.connect("dead", self, "_on_unit_dead")
	unit.connect("take_damage", self, "_on_unit_take_damage")
	unit.connect("reset", self, "_on_unit_reset")

	if unit is Infantry:
		ammo_bar.max_value = unit.get_total_ammo()
		ammo_bar.value = unit.get_total_ammo()
		unit.connect("ammo_updated", self, "_on_unit_ammo_updated")
	
func _on_unit_ammo_updated(_unit :Infantry, remain_ammo :int, max_ammo :int):
	ammo_bar.max_value = max_ammo
	ammo_bar.value = remain_ammo
	
func _on_unit_take_damage(unit :BaseUnit, _damage :int, _from :Vector3, _by :String):
	hp_bar.update_bar(unit.hp, unit.max_hp)
	
func _on_unit_dead(unit :BaseUnit, _from :Vector3, _by :String):
	panel_3.visible = true
	hp_bar.update_bar(unit.hp, unit.max_hp)
	
func _on_unit_reset(unit :BaseUnit):
	panel_3.visible = false
	hp_bar.update_bar(unit.hp, unit.max_hp)
	
	

