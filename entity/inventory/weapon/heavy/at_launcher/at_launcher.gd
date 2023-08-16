extends Weapon

onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var damage_area = $damage_area

func _ready():
	damage_area.set_as_toplevel(true)
	damage_area.set_deferred("monitoring", false)

func fire():
	if has_ammo():
		animation_player.play("fire")
		
		audio_stream_player_3d.unit_size = 6
		audio_stream_player_3d.stream = preload("res://assets/sounds/explosions/missile_away.wav")
		audio_stream_player_3d.play()
	
	if is_master and not damage_area.monitoring:
		damage_area.set_deferred("monitoring", true)
	
	if is_instance_valid(target):
		damage_area.translation = target.global_transform.origin
		
	.fire()
	
func _reload_finish():
	._reload_finish()
	
	audio_stream_player_3d.unit_size = 1
	audio_stream_player_3d.stream = preload("res://assets/sounds/weapon/handgun/reload.wav")
	audio_stream_player_3d.play()

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
			# damage to building should be diffrent
			# latter maybe
			body.take_damage(damage)
	
func add_weapon_mod(_mod :WeaponMod):
	.add_weapon_mod(_mod)
	
	if _mod.type_mod == WeaponMod.typeMod.scope:
		_mod.visible = false

























