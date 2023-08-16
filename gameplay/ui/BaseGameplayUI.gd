extends Control
class_name BaseGameplayUi

signal switch_unit(unit)
signal switch_weapon(weapon)
signal switch_item(item)
signal cycle_weapon
signal reload
signal retreat
signal main_menu

export var squad_info_holder :NodePath
onready var _squad_info_holder :Control = get_node_or_null(squad_info_holder)

export var unit_inventory_holder :NodePath
onready var _unit_inventory_holder :Control = get_node_or_null(unit_inventory_holder)

func show_joystick(_val :bool):
	pass

func get_joystick_output(_basis :Basis) -> Vector3:
	return Vector3.ZERO

func set_crosshair_position(_pos :Vector2):
	pass
	
#########################################################################################
	
func add_infantry_info(data :InfantryData, unit :BaseUnit):
	var info :InfantryInfo = preload("res://assets/ui/gameplay/infantry_info/infantry_info.tscn").instance()
	info.connect("pressed", self, "on_switch_infantry", [info, unit])
	_squad_info_holder.add_child(info)
	info.set_infantry_info(data, unit)
	
	# just trigger to
	# current selected unit
	if _squad_info_holder.get_child_count() == 1:
		_squad_info_holder.get_child(0).set_selected(true)
	
func on_switch_infantry(info :InfantryInfo, unit :BaseUnit):
	for _info in _squad_info_holder.get_children():
		_info.set_selected(false)
		
	info.set_selected(true)
	
	emit_signal("switch_unit", unit)
	
#########################################################################################
	
func refresh_inventory_info(unit :BaseUnit):
	for i in _unit_inventory_holder.get_children():
		_unit_inventory_holder.remove_child(i)
		i.queue_free()
		
	if unit.is_dead:
		return
		
	if unit is Infantry:
		for i in unit.inventories:
			if i is Weapon:
				var info :WeaponInfo = preload("res://assets/ui/gameplay/weapon_info/weapon_info.tscn").instance()
				info.weapon = i
				_unit_inventory_holder.add_child(info)
				info.connect("pressed", self, "on_switch_weapon", [info, i])
				info.set_selected(unit.equiped_weapon == i)
				
			else:
				var info :InventoryInfo = preload("res://assets/ui/gameplay/inventory_info/inventory_info.tscn").instance()
				info.item = i
				_unit_inventory_holder.add_child(info)
				info.connect("pressed", self, "on_switch_item", [info, i])
				info.set_selected(unit.equiped_item == i)
	
func on_switch_weapon(info :WeaponInfo, weapon :Weapon):
	for i in _unit_inventory_holder.get_children():
		i.set_selected(false)
		
	info.set_selected(true)
	emit_signal("switch_weapon", weapon)
	
func on_switch_item(info :InventoryInfo, item :Inventory):
	for i in _unit_inventory_holder.get_children():
		i.set_selected(false)
		
	info.set_selected(true)
	emit_signal("switch_item", item)
	
#########################################################################################
func update_unit_weapon_info(_unit : Infantry):
	pass

func update_player_target_info(_data :InfantryData, _unit :BaseUnit):
	pass

func enable_retreat_button(_val :bool):
	pass

func update_compass(_rotation :float, _pos :Vector3, _target :Vector3):
	pass
#########################################################################################
func show_menu():
	pass
	
#########################################################################################
func on_reload():
	emit_signal("reload")
	
func on_retreat():
	emit_signal("retreat")
	
func on_cycle_weapon():
	emit_signal("cycle_weapon")
	
func on_main_menu():
	emit_signal("main_menu")

















