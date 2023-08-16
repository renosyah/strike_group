extends GroundUnit
class_name Infantry

signal ammo_updated(_unit, _remain, _max)

const dead_sounds :Array = [
	preload("res://assets/sounds/infantry/maledeath1.wav"),
	preload("res://assets/sounds/infantry/maledeath2.wav"),
	preload("res://assets/sounds/infantry/maledeath3.wav"),
	preload("res://assets/sounds/infantry/maledeath4.wav")
]

onready var inventories :Array = []
onready var gears :Array = []

export var equip_right_hand_position :NodePath
export var equip_left_hand_position :NodePath
export var equip_body_position :NodePath
export var equip_head_position :NodePath
export var equip_back_position :NodePath
export var equip_face_position :NodePath

onready var _equip_right_hand_position :Spatial = get_node_or_null(equip_right_hand_position)
onready var _equip_left_hand_position :Spatial = get_node_or_null(equip_left_hand_position)
onready var _equip_body_position :Spatial = get_node_or_null(equip_body_position)
onready var _equip_head_position :Spatial = get_node_or_null(equip_head_position)
onready var _equip_back_position :Spatial = get_node_or_null(equip_back_position)
onready var _equip_face_position :Spatial = get_node_or_null(equip_face_position)

onready var aim_position :Vector3

var equiped_weapon :Weapon
var equiped_item :Inventory

var _armor :int = 0

remotesync func _dead(_from :Vector3, _by :String):
	._dead(_from, _by)
	
	if is_instance_valid(equiped_item):
		if equiped_item is SupportItem:
			equiped_item.use(false)
		
		
	_sound.stream = dead_sounds[rand_range(0, dead_sounds.size())]
	_sound.play()
	
remotesync func _reset():
	._reset()
	
	if is_instance_valid(equiped_item):
		if equiped_item is SupportItem:
			equiped_item.use(true)
			
func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if offline_mode:
		return
	
	if not enable_network:
		return
		
	if not _is_master or not _is_online:
		return
		
	rset_unreliable("_puppet_aim_position", aim_position)
	
puppet var _puppet_aim_position :Vector3

func _ready():
	_aim_crosshair()
	
func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	_aim_crosshair()
	_aim_crosshair_to_target(delta)
	
func puppet_moving(delta :float) -> void:
	.puppet_moving(delta)
	
	if not enable_network or not _puppet_ready:
		return
		
	aim_position = _puppet_aim_position
	
func _aim_crosshair():
	var _offset :int = int(clamp(final_attack_range, 5, final_attack_range))
	var _from_pos :Vector3 = global_transform.origin
	var _to_pos :Vector3 = _from_pos + -global_transform.basis.z * (_offset - 2)
	aim_position = _to_pos
	
func _aim_crosshair_to_target(delta :float):
	if not is_instance_valid(target):
		return
		
	if target.is_dead:
		return
		
	var target_pos :Vector3
	
	if target is BaseUnit:
		target_pos = target.global_transform.origin
		
	elif target is BaseBuilding:
		target_pos = target.global_transform.origin
		
	var from_pos :Vector3 = global_transform.origin
	var is_align = _is_align(target_pos)
	var dist :float = from_pos.distance_to(target_pos)
	
	if is_align and dist < final_attack_range and dist > min_attack_range:
		aim_position = target_pos
		
		# force body rotate
		# facing toward aim position
		_pivot.look_at(target_pos, Vector3.UP)
		_pivot.rotation_degrees.y = wrapf(_pivot.rotation_degrees.y, 0.0, 360.0)
		_pivot.rotation_degrees.x = clamp(_pivot.rotation_degrees.x, -45, 45)
		rotation.y = lerp_angle(rotation.y, _pivot.rotation.y, 5 * delta)
	
func perform_attack():
	.perform_attack()
	
	if not is_instance_valid(target):
		return
	
	if not is_instance_valid(equiped_weapon):
		return
		
	if equiped_weapon.is_reloading():
		return
		
	equiped_weapon.target = target
	equiped_weapon.fire()
	
func take_damage(_damage :int, _from :Vector3, _by :String):
	.take_damage(int(clamp(_damage - _armor, 1, _damage)), _from, _by)
	
############################################################
# for bot
func switch_weapon():
	if not _is_master:
		return
		
	if inventories.empty():
		return
		
	if is_instance_valid(equiped_weapon):
		var w :Weapon = equiped_weapon
		if w.ammo < w.max_ammo and w.can_reload():
			reload_weapon()
			return
		
	for item in inventories:
		if item is Weapon:
			if item.can_reload():
				equip_weapon(item)
				return
	
func get_total_ammo() -> int:
	var _total_ammo :int = 0
	for item in inventories:
		if item is Weapon:
			_total_ammo += item.max_ammo_pool
			
	return _total_ammo
	
func get_remaining_ammo() -> int:
	var _ammo :int = 0
	for item in inventories:
		if item is Weapon:
			_ammo += item.ammo_pool
			
	return _ammo
	
############################################################
func equip_weapon(_weapon :Weapon, _sync :bool = true):
	if is_dead:
		return
		
	if not is_instance_valid(_weapon):
		return
		
	if not _sync or offline_mode:
		_equip_weapon(_weapon.get_path())
		return
		
	if not _is_master:
		return
		
	rpc("_equip_weapon", _weapon.get_path())
	
remotesync func _equip_weapon(_weapon_path :NodePath):
	var _weapon :Weapon = get_node_or_null(_weapon_path)
	if not is_instance_valid(_weapon):
		return
		
	if not inventories.has(_weapon):
		inventories.append(_weapon)
		
	# no need to call
	# rpc function again
	_unequip_hand()
	
	final_attack_range = _weapon.get_attack_range()
	_weapon.unit_attack_damage = attack_damage
	_weapon.apply_mod()
	
	final_attack_delay = _weapon.get_attack_delay()
	_attack_delay_timer.wait_time = final_attack_delay
	_attack_delay_timer.start()
	
	# detach from previous parent
	var weapon_parent :Node = _weapon.get_parent()
	if is_instance_valid(weapon_parent):
		weapon_parent.remove_child(_weapon)
		
	_equip_right_hand_position.add_child(_weapon)
	weapon_equiped(_weapon)
	
func weapon_equiped(_weapon :Weapon):
	_weapon.rotation = Vector3.ZERO
	_weapon.translation = Vector3.ZERO
	
	equiped_weapon = _weapon
	equiped_weapon.is_master = _is_master
	equiped_weapon.visible = true
	
	if is_instance_valid(unit_spotter):
		unit_spotter.set_detection_range(int(final_attack_range))
		
############################################################
func reload_weapon(_sync :bool = true):
	if is_dead:
		return
		
	if not _sync or offline_mode:
		_on_reload_weapon()
		return
		
	if not _is_master:
		return
		
	rpc("_on_reload_weapon")
	
remotesync func _on_reload_weapon():
	if not is_instance_valid(equiped_weapon):
		return
		
	if equiped_weapon.is_reloading():
		return
		
	if not equiped_weapon.can_reload():
		return
		
	equiped_weapon.reload()
	on_reload_weapon()
	
func on_reload_weapon():
	if is_instance_valid(equiped_weapon):
		yield(equiped_weapon, "weapon_reloaded")
		emit_signal("ammo_updated", self, get_remaining_ammo(), get_total_ammo())
	
############################################################
func heal(_add_hp :int):
	if is_dead:
		return
		
	if offline_mode:
		_heal(_add_hp)
		
	else:
		rpc("_heal", _add_hp)
	
remotesync func _heal(_add_hp :int):
	hp = int(clamp(hp + _add_hp, 0, max_hp))
	
	# trigger update hp
	_take_damage(0, hp, Vector3.ZERO, "")
	
func rearm():
	if is_dead:
		return
		
	if offline_mode:
		_rearm()
		
	else:
		rpc("_rearm")
	
remotesync func _rearm():
	if inventories.empty():
		return
		
	for item in inventories:
		if item is Weapon:
			var _add_ammo :int = item.max_ammo
			item.ammo_pool = clamp(item.ammo_pool + _add_ammo, 0, item.max_ammo_pool)
			
	emit_signal("ammo_updated", self, get_remaining_ammo(), get_total_ammo())
	
############################################################
func equip_item(item :Inventory, _sync :bool = true):
	if is_dead:
		return
		
	if not is_instance_valid(item):
		return
		
	if not _sync or offline_mode:
		_equip_item(item.get_path())
		return
		
	if not _is_master:
		return
		
	rpc("_equip_item", item.get_path())
	
remotesync func _equip_item(_item_path :NodePath):
	var _item :Inventory = get_node_or_null(_item_path)
	if not is_instance_valid(_item):
		return
		
	if not inventories.has(_item):
		inventories.append(_item)
		
	# no need to call
	# rpc function again
	_unequip_hand()
	
	# detach from previous parent
	var item_parent :Node = _item.get_parent()
	if is_instance_valid(item_parent):
		item_parent.remove_child(_item)
		
	_equip_right_hand_position.add_child(_item)
	
	item_equiped(_item)
	
func item_equiped(_item :Inventory):
	_item.rotation = Vector3.ZERO
	_item.translation = Vector3.ZERO
	
	equiped_item = _item
	equiped_item.is_master = _is_master
	equiped_item.visible = true
	
	equiped_item.team = team
	
	if equiped_item is SupportItem:
		equiped_item.display_area = not offline_mode
		equiped_item.use(true)
	
############################################################
func unequip_hand(_sync :bool = true):
	if is_dead:
		return
		
	if not _sync or offline_mode:
		_unequip_hand()
		return
		
	if not _is_master:
		return
		
	rpc("_unequip_hand")
	
remotesync func _unequip_hand():
	if is_instance_valid(equiped_weapon):
		if _equip_right_hand_position.get_children().has(equiped_weapon):
			_equip_right_hand_position.remove_child(equiped_weapon)
			add_child(equiped_weapon)
			equiped_weapon.visible = false
			
		equiped_weapon = null
		
		final_attack_range = attack_range
		
		final_attack_delay = attack_delay
		_attack_delay_timer.wait_time = final_attack_delay
		
	elif is_instance_valid(equiped_item):
		if _equip_right_hand_position.get_children().has(equiped_item):
			_equip_right_hand_position.remove_child(equiped_item)
			add_child(equiped_item)
			equiped_item.visible = false
			
			if equiped_item is SupportItem:
				equiped_item.use(false)
			
		equiped_item = null
		
	hand_unequip()
	
func hand_unequip():
	if not is_instance_valid(equiped_weapon) and is_instance_valid(unit_spotter):
		unit_spotter.set_detection_range(unit_spotter.detection_range)
		
############################################################
func equip_gear(_gear :Gear, _sync :bool = true):
	if is_dead:
		return
		
	if not is_instance_valid(_gear):
		return
		
	# check if already wear it
	match (_gear.type_gear):
		Gear.typeGear.head_gear:
			if _equip_head_position.get_child_count() > 0:
				return
				
		Gear.typeGear.face_wear:
			if _equip_face_position.get_child_count() > 0:
				return
				
		Gear.typeGear.body_armor:
			if _equip_body_position.get_child_count() > 0:
				return
				
		Gear.typeGear.backpack:
			if _equip_back_position.get_child_count() > 0:
				return
			
	if not _sync or offline_mode:
		_equip_gear(_gear.get_path())
		return
		
	if not _is_master:
		return
		
	rpc("_equip_gear", _gear.get_path())
	
remotesync func _equip_gear(_gear_path :NodePath):
	var _gear :Gear = get_node_or_null(_gear_path)
	if not is_instance_valid(_gear):
		return
		
	if not gears.has(_gear):
		gears.append(_gear)
		
	# detach from previous parent
	var item_parent :Node = _gear.get_parent()
	if is_instance_valid(item_parent):
		item_parent.remove_child(_gear)

	# wear apropriate position
	match (_gear.type_gear):
		Gear.typeGear.head_gear:
			_equip_head_position.add_child(_gear)
			gear_equiped(_gear)
			
		Gear.typeGear.face_wear:
			_equip_face_position.add_child(_gear)
			gear_equiped(_gear)
				
		Gear.typeGear.body_armor:
			_equip_body_position.add_child(_gear)
			gear_equiped(_gear)
			
		Gear.typeGear.backpack:
			_equip_back_position.add_child(_gear)
			gear_equiped(_gear)
			
func gear_equiped(_gear :Gear):
	_gear.rotation = Vector3.ZERO
	_gear.translation = Vector3.ZERO
	_refresh_stat()
	
func _refresh_stat():
	_armor = 0
	
	var _armor_gears_type :Array = [
		Gear.typeGear.head_gear,
		Gear.typeGear.body_armor
	]
	
	for i in gears:
		var _armor_gear :Gear = i
		if _armor_gears_type.has(_armor_gear.typeGear):
			_armor += _armor_gear.armor
			
############################################################
func destroy_inventory(_item :Inventory, _sync :bool = true):
	if not is_instance_valid(_item):
		return
		
	if is_dead:
		return
		
	if not _sync or offline_mode:
		_destroy_inventory(_item.get_path())
		return
		
	if not _is_master:
		return
		
	rpc("_destroy_inventory", _item.get_path())
	
remotesync func _destroy_inventory(_item_path :NodePath):
	var _item :Inventory = get_node_or_null(_item_path)
	if not is_instance_valid(_item):
		return
		
	if _item == equiped_weapon or _item == equiped_item:
		_unequip_hand()
		
	if inventories.has(_item):
		inventories.erase(_item)
		
	if gears.has(_item):
		gears.erase(_item)
		
	_item.get_parent().remove_child(_item)
	_item.queue_free()
	
	inventory_destroyed()
	
func inventory_destroyed():
	_refresh_stat()
	
############################################################
func revive(_sync :bool = true):
	if not _sync or offline_mode:
		_revive()
		return
		
	rpc("_revive")
	
remotesync func _revive():
	_reset()
	hp = int(max_hp * 0.25)
	_take_damage(0, hp, Vector3.ZERO, "")
	
############################################################
func _check_target():
	#_check_target()
	
	target = null
	
	if not is_instance_valid(unit_spotter):
		return
	
	target =_get_closes_target(
		global_transform.origin if is_bot else aim_position,
		unit_spotter.get_alive_unit_targets()
	)
	
	if is_instance_valid(target):
		return
		
	target =_get_closes_target(
		global_transform.origin if is_bot else aim_position,
		unit_spotter.get_alive_building_targets()
	)
	





























