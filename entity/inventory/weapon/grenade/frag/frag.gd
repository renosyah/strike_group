extends Weapon

onready var damage_area = $damage_area
onready var mesh_instance = $MeshInstance

func _ready():
	damage_area.set_as_toplevel(true)
	damage_area.set_deferred("monitoring", false)

func fire():
	.fire()
	
	visible = has_ammo()
	
	if is_master and not damage_area.monitoring:
		damage_area.set_deferred("monitoring", true)
	
	if is_instance_valid(target):
		damage_area.translation = target.global_transform.origin
		
func prepare_projectile():
	#.prepare_projectile()
	
	var last_index = get_tree().get_root().get_child_count() - 1
	
	for _i in 5:
		var bullet :Projectile = projectile.instance()
		bullet.is_master = is_master
		bullet.connect("reach", self , "on_bullet_reach_target")
		get_tree().get_root().get_child(last_index).add_child(bullet)
		bullet.copy_mesh(mesh_instance)
		_bullets.append(bullet)
		
		
func _reload_finish():
	._reload_finish()
	
	visible = has_ammo()
	
func on_bullet_reach_target(_projectile :Projectile, _target):
	#.on_bullet_reach_target(_projectile, _target)
	
	if not is_master:
		return
		
	var modifier :int = int(attack_damage * 0.25)
	var damage :int = int(rand_range(attack_damage - modifier,attack_damage + modifier))
	
	for body in damage_area.get_overlapping_bodies():
		if body is BaseUnit:
			body.take_damage(damage, _projectile.get_direction(), player_id)
			
		elif body is BaseBuilding:
			body.take_damage(damage)
			
func add_weapon_mod(_mod :WeaponMod):
	#.add_weapon_mod(_mod)
	
	_mod.visible = false
