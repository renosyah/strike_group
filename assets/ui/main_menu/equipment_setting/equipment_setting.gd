extends Control

onready var head_gear = Global.get_files("res://data/inventory/gear/head_gear/list/")
onready var face_gear = Global.get_files("res://data/inventory/gear/facewear/list/")
onready var armor = Global.get_files("res://data/inventory/gear/body_armor/list/")
onready var backpack = Global.get_files("res://data/inventory/gear/backpack/list/")

onready var primary_weapons = Global.get_files("res://data/inventory/weapon/primary/")
onready var secondary_weapons = Global.get_files("res://data/inventory/weapon/secondary/")
onready var special = Global.get_files("res://data/inventory/weapon/special/")
onready var support_item = Global.get_files("res://data/inventory/support_item/list/")

signal display(_show)

var unit :Infantry
var data :InfantryData

var back_direction :Vector3
var foward_direction :Vector3

var cicle_headgear :int = 0
var cicle_facegear :int = 0
var cicle_armor :int = 0
var cicle_backpack :int = 0

var cicle_primary :int = 0
var cicle_secondary :int = 0
var cicle_special :int = 0
var cicle_support:int = 0

onready var player_name = $unit_info/player_name
onready var animation_player = $AnimationPlayer
onready var options = [
	$left_set/head_gear, $left_set/face_wear, $left_set/body_armor, $left_set/backpack,
	$right_set/primary, $right_set/secondary, $right_set/special, $right_set/support
]

func reset():
	if is_instance_valid(unit):
		unit.face_direction = foward_direction
		unit = null
		
	data = null
	
func display(_show :bool, _data :InfantryData, _unit :Infantry):
	reset()
	
	unit = _unit
	data = _data
	
	player_name.text = data.entity_name
	
	foward_direction = -unit.global_transform.basis.z
	back_direction = unit.global_transform.basis.z
		
	if _show:
		visible = true
		animation_player.play("show")
		yield(animation_player, "animation_finished")
		
	else:
		unit = null
		data = null
		animation_player.play_backwards("show")
		yield(animation_player, "animation_finished")
		visible = false
		
	emit_signal("display", _show)
	
func uncheck_all(button):
	for i in options:
		if i != button:
			i.set_selected(false)
		
func _on_head_gear_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var gear :GearData = head_gear[cicle_headgear].duplicate()
	gear.node_name = "head_gear_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_gear(gear.node_name)
	_destroy_inventory(gear.node_name)
	
	unit.equip_gear(gear.spawn_gear(unit))
	data.gears.append(gear)
	
	Global.save_player_units()
	
	cicle_headgear += 1
	
	if cicle_headgear > head_gear.size() - 1:
		cicle_headgear = 0
		
		
func _on_body_armor_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var gear :GearData = armor[cicle_armor].duplicate()
	gear.node_name = "armor_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_gear(gear.node_name)
	_destroy_inventory(gear.node_name)
	
	unit.equip_gear(gear.spawn_gear(unit))
	data.gears.append(gear)
	
	Global.save_player_units()
	
	cicle_armor += 1
	
	if cicle_armor> armor.size() - 1:
		cicle_armor = 0
	
func _on_backpack_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var gear :GearData = backpack[cicle_backpack].duplicate()
	gear.node_name = "backpack_%s" % unit.player_id
	
	unit.face_direction = back_direction
	
	_remove_gear(gear.node_name)
	_destroy_inventory(gear.node_name)
	
	unit.equip_gear(gear.spawn_gear(unit))
	data.gears.append(gear)
	
	Global.save_player_units()
	
	cicle_backpack += 1
	
	if cicle_backpack > backpack.size() - 1:
		cicle_backpack = 0
	
func _on_face_wear_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var gear :GearData = face_gear[cicle_facegear].duplicate()
	gear.node_name = "cicle_facegear_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_gear(gear.node_name)
	_destroy_inventory(gear.node_name)
	
	unit.equip_gear(gear.spawn_gear(unit))
	data.gears.append(gear)
	
	Global.save_player_units()
	
	cicle_facegear += 1
	
	if cicle_facegear > face_gear.size() - 1:
		cicle_facegear = 0
		
		
	
func _on_primary_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var weapon :WeaponData = primary_weapons[cicle_primary].duplicate()
	weapon.node_name = "primary_weapons_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_inventory(weapon.node_name)
	_destroy_inventory(weapon.node_name)
	
	unit.equip_weapon(weapon.spawn_weapon(unit))
	data.weapon = weapon
	
	Global.save_player_units()
	
	cicle_primary += 1
	
	if cicle_primary > primary_weapons.size() - 1:
		cicle_primary = 0
	
	
func _on_secondary_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var weapon :WeaponData = secondary_weapons[cicle_secondary].duplicate()
	weapon.node_name = "secondary_weapons_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_inventory(weapon.node_name)
	_destroy_inventory(weapon.node_name)
	
	unit.equip_weapon(weapon.spawn_weapon(unit))
	data.inventories.append(weapon)
	
	Global.save_player_units()
	
	cicle_secondary += 1
	
	if cicle_secondary > secondary_weapons.size() - 1:
		cicle_secondary = 0
	
	
func _on_special_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var item :WeaponData = special[cicle_special].duplicate()
	item.node_name = "special_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_inventory(item.node_name)
	_destroy_inventory(item.node_name)
	
	unit.equip_weapon(item.spawn_inventory(unit))
	data.inventories.append(item)
	
	Global.save_player_units()
	
	cicle_special += 1
	
	if cicle_special > special.size() - 1:
		cicle_special = 0

func _on_support_pressed(button):
	uncheck_all(button)
	button.set_selected(not button.is_selected)
	
	var item :SupportItemData = support_item[cicle_support].duplicate()
	item.node_name = "support_%s" % unit.player_id
	
	unit.face_direction = foward_direction
	
	_remove_inventory(item.node_name)
	_destroy_inventory(item.node_name)
	
	unit.equip_item(item.spawn_inventory(unit))
	data.inventories.append(item)
	
	Global.save_player_units()
	
	cicle_support += 1
	
	if cicle_support > support_item.size() - 1:
		cicle_support = 0
	
func _destroy_inventory(_name :String):
	for item in unit.inventories + unit.gears:
		if item.name == _name:
			unit.destroy_inventory(item)
			return
	
func _remove_gear(_name :String):
	for i in data.gears:
		if i.node_name == _name:
			data.gears.erase(i)
			
func _remove_inventory(_name :String):
	for i in data.inventories:
		if i.node_name == _name:
			data.inventories.erase(i)











