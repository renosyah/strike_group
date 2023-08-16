extends Spatial
class_name SquadFormation

export var row_size :int = 2
export var space :int = 2
export var force_follow :bool = true
export var enable_debug :bool

var current_squad_member :int = 0
var squad_leader :Infantry
var squad_members :Array = []
var retreat_point :Vector3

onready var _retreat_cooldown = $retreat_cooldown
onready var _disable_squad_input_cooldown = $disable_squad_input_cooldown
onready var _squad_member_position :Array = []
onready var _debug_mesh = $debug_mesh
var _last_equiped_item :Dictionary = {}

func create_squad():
	if squad_members.empty():
		return
		
	for i in squad_members:
		i.is_bot = true
		
	# choose squad leader
	squad_leader = squad_members[current_squad_member]
	squad_leader.is_bot = false
	squad_leader.speed_modifier = 1
	
#	for i in squad_members:
#		var unit :Infantry = i
#		var spotter :UnitSpotter = unit.unit_spotter
#		if not is_instance_valid(spotter):
#			continue
#
#		if not spotter.is_connected("on_target_added", self, "_on_leader_on_target_added"):
#			spotter.connect("on_target_added", self, "_on_leader_on_target_added",[unit])
#
#		if not spotter.is_connected("on_target_removed", self, "_on_leader_on_target_removed"):
#			spotter.connect("on_target_removed", self, "_on_leader_on_target_removed",[unit])
	
	# exclude squad leader
	var _squad_member_size = squad_members.size() - 1
	if _squad_member_size == 0:
		return
	
	for i in _squad_member_position:
		var spat :Position3D = i
		spat.queue_free()
		
	_squad_member_position.clear()
	
	var formation :Array = generate_circle_formation(_squad_member_size, space)
	for pos in formation:
		var position_3d :Position3D = Position3D.new()
		add_child(position_3d)
		position_3d.translation = pos
		
		if enable_debug:
			var mesh = _debug_mesh.duplicate()
			mesh.visible = true
			position_3d.add_child(mesh)
		
		_squad_member_position.insert(0, position_3d)
		
	_retreat_cooldown.start()
	
func order_retreat():
	if not can_retreat():
		return
		
	if squad_leader.is_dead:
		return
		
	set_process(false)
	
	squad_leader.is_bot = true
	squad_leader.speed_modifier = 2
	squad_leader.is_moving = true
	squad_leader.move_to = retreat_point
	
	translation = retreat_point
	
	var index :int = 0
	for i in squad_members:
		var bot :Infantry = i
		if bot.is_dead:
			continue
			
		_last_equiped_item[bot] = {"weapon" : bot.equiped_weapon, "item" : bot.equiped_item}
		bot.unequip_hand()
		
		if bot != squad_leader:
			var pos :Vector3 = _get_member_position(index)
			bot.is_moving = true
			bot.force_bot_move = true
			bot.move_to = pos
			bot.speed_modifier = 2
			
			index += 1
		
	_disable_squad_input_cooldown.start()
	_retreat_cooldown.start()
	
func _on_disable_squad_input_cooldown_timeout():
	set_process(true)
	
	squad_leader.speed_modifier = 1
	
	for i in _last_equiped_item.keys():
		var bot :Infantry = i
		bot.equip_weapon(_last_equiped_item[bot]["weapon"])
		bot.equip_item(_last_equiped_item[bot]["item"])
	
func can_retreat() -> bool:
	if not is_instance_valid(squad_leader):
		return false
		
	var is_not_cooldown :bool = _retreat_cooldown.is_stopped()
	return not is_retreating() and not squad_leader.is_dead and is_not_cooldown
	
func is_retreating() -> bool:
	return not _disable_squad_input_cooldown.is_stopped()
	
func _get_member_position(at :int) -> Vector3:
	var is_valid :Array = [
		at < 0, at > _squad_member_position.size() - 1,
		_squad_member_position.empty()
	]
	if is_valid.has(true):
		return global_transform.origin
		
	return _squad_member_position[at].global_transform.origin
	
func _process(_delta):
	if not is_instance_valid(squad_leader):
		return
		
	var leader_pos :Vector3 = squad_leader.global_transform.origin
	
	if not squad_leader.is_dead:
		var leader_basis_z :Vector3 = squad_leader.global_transform.basis.z
		var velocity_length :float = 2 * squad_leader.move_direction.length()
		
		translation = leader_pos + (-leader_basis_z * velocity_length)
		rotation = squad_leader.global_rotation
		
	var index :int = 0
	for i in squad_members:
		var bot :Infantry = i
		
		var valids :Array = [
			bot.is_bot,
			bot != squad_leader,
			not bot.is_dead,
		]
		
		if valids.has(false):
			bot.force_bot_move = false
			bot.speed_modifier = 1
			continue
			
		var pos :Vector3 = _get_member_position(index)
		var dist_to_pos :float = bot.global_transform.origin.distance_to(pos)
		var squad_on_move :bool = squad_leader.has_momentum() and force_follow
		var has_target :bool = is_instance_valid(bot.target)
		
		bot.is_moving = true
		bot.force_bot_move = squad_on_move
		bot.move_to = pos
		
		if has_target:
			bot.speed_modifier = clamp(dist_to_pos, 1.0, 2.0) if squad_on_move else 1.0
			
		else:
			bot.speed_modifier = clamp(dist_to_pos, 1.0, 2.0) 
			
		index += 1

func _on_leader_on_target_added(target, current_unit :Infantry):
	if current_unit != squad_leader:
		return
		
	for i in squad_members:
		var unit :Infantry = i
		if unit == squad_leader:
			continue
			
		var spotter :UnitSpotter = unit.unit_spotter
		if is_instance_valid(spotter):
			spotter.append_targets([target])
	
func _on_leader_on_target_removed(target, current_unit :Infantry):
	if current_unit != squad_leader:
		return
		
	for i in squad_members:
		var unit :Infantry = i
		if unit == squad_leader:
			continue
			
		var spotter :UnitSpotter = unit.unit_spotter
		if is_instance_valid(spotter):
			spotter.remove_targets([target])
	

func generate_circle_formation(max_unit :int, formation_space :int) -> Array:
	var formations = []
	for i in range(max_unit + 1):
		var angle = i / float(max_unit) * TAU
		var p = Vector3.RIGHT.rotated(Vector3.DOWN, angle)
		formations.append(p * formation_space)
		
	return formations
	
func _get_formation_box(max_unit :int, formation_space :int) -> Array:
	var pos :Vector3 = Vector3.ZERO
	if max_unit <= 1:
		return [pos]
		
	var formations = []
	var s_side = round(sqrt(max_unit))
	var unit_pos = pos - formation_space * Vector3(s_side/2,pos.y, s_side/2)
	
	for i in max_unit:
		unit_pos.y = pos.y
		formations.append(unit_pos)
		unit_pos.x += formation_space
		if unit_pos.x > (pos.x + s_side * formation_space / 2):
			unit_pos.z += formation_space
			unit_pos.x = pos.x - formation_space * s_side / 2
			
	return formations



