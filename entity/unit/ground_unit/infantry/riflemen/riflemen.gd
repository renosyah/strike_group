extends Infantry

onready var _iks = [
	$body/Armature/Skeleton/hand_l,
	$body/Armature/Skeleton/hand_r,
	$body/Armature/Skeleton/body,
	$body/Armature/Skeleton/leg_l,
	$body/Armature/Skeleton/leg_r
]

onready var collision_shape = $CollisionShape

onready var _upper_body_animation_tree = $body/AnimationTree.get("parameters/playback")
onready var _body_animation_tree = $AnimationTree.get("parameters/playback")
onready var _body = $body/body

onready var _mesh :MeshInstance = $body/Armature/Skeleton/Cube_Cube001
onready var _uniform_1 :SpatialMaterial = _mesh.get_surface_material(2).duplicate()

func _ready():
	_enable_ik(true)
	_uniform_1.albedo_color = color_coat
	_mesh.set_surface_material(2, _uniform_1)
	
func _enable_ik(_enable :bool):
	for i in _iks:
		var item :SkeletonIK = i
		if _enable:
			if not item.is_running():
				item.start(false)
				
		else:
			if item.is_running():
				item.stop()
		
	
func on_camera_entered(_camera :Camera):
	.on_camera_entered(_camera)
	
	_enable_ik(true)
	
func on_camera_exited(_camera :Camera):
	.on_camera_exited(_camera)
	
	_enable_ik(false)

func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_dead:
		return
		
	var _input_power :float = move_direction.length()
	var _is_moving :bool = _input_power > 0.1
	
	_animation_states["body"] = "walk" if _is_moving else "idle"
	
func moving(delta :float) -> void:
	.moving(delta)
	
	if _animation_states.has("body"):
		_body_animation_tree.travel(_animation_states["body"])
	
	if not is_dead:
		_body.look_at(aim_position, Vector3.UP)
	
func perform_attack():
	var has_ammo :bool 
	
	if is_instance_valid(equiped_weapon):
		has_ammo = equiped_weapon.has_ammo()
	
	.perform_attack()
	
	if is_dead:
		return
	
	if not is_instance_valid(equiped_weapon):
		return
		
	if has_ammo:
		_upper_body_animation_tree.travel(equiped_weapon.fire_animation)
	
	if not equiped_weapon.has_ammo():
		if not equiped_weapon.can_reload():
			switch_weapon()
			return
			
		reload_weapon(false)
		
func weapon_equiped(_weapon :Weapon):
	.weapon_equiped(_weapon)
	
	if is_dead:
		return
		
	_upper_body_animation_tree.travel(_weapon.equip_animation)
	
func item_equiped(_item :Inventory):
	.item_equiped(_item)
	
	if is_dead:
		return
		
	_upper_body_animation_tree.travel(_item.equip_animation)
	
func hand_unequip():
	.hand_unequip()
	
	_upper_body_animation_tree.travel("idle")
	
func on_reload_weapon():
	.on_reload_weapon()
	
	if is_dead:
		return
		
	if equiped_weapon.reload_animation.empty():
		return
		
	if is_instance_valid(equiped_weapon):
		_upper_body_animation_tree.travel(equiped_weapon.reload_animation)
		
remotesync func _dead(_from :Vector3, _by :String):
	._dead(_from, _by)
	
	_upper_body_animation_tree.travel("idle")
	_animation_states["body"] = "dead"
	
remotesync func _reset():
	._reset()
	
	if is_instance_valid(equiped_weapon):
		_upper_body_animation_tree.travel(equiped_weapon.equip_animation)
		return
		
	if is_instance_valid(equiped_item):
		_upper_body_animation_tree.travel(equiped_item.equip_animation)
		return
		
	_upper_body_animation_tree.travel("idle")
	














