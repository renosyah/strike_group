extends Weapon

onready var _damage_area = $damage_area
onready var _turn_off_timer = $turn_off_timer
onready var _fire = $fire
onready var _flame = $flame

func _ready():
	_damage_area.set_deferred("monitoring", false)
	
func prepare_projectile():
	#.prepare_projectile()
	# no projectile needed
	pass
	
func fire():
	#.fire()
	
	if is_master and not _damage_area.monitoring:
		_damage_area.set_deferred("monitoring", true)
		yield(get_tree(), "idle_frame")
		
	if is_reloading():
		return
		
	if not has_ammo():
		return
		
	ammo -= 1
	
	if _turn_off_timer.is_stopped():
		_turn_off_timer.start()
		
		_fire.emitting = false
		_flame.emitting = true
		
	if not is_master:
		return
		
	for body in _damage_area.get_overlapping_bodies():
		if body is BaseUnit:
			var damage :int = int(body.max_hp * 0.25)
			body.take_damage(damage, -global_transform.basis.z, player_id)
			
		elif body is BaseBuilding:
			var damage :int = int(body.max_hp * 0.15)
			body.take_damage(damage)
	
func add_weapon_mod(_mod :WeaponMod):
	.add_weapon_mod(_mod)
	
	if _mod.type_mod == WeaponMod.typeMod.scope:
		_mod.visible = false
		
func _on_turn_off_timer_timeout():
	_fire.emitting = true
	_flame.emitting = false












