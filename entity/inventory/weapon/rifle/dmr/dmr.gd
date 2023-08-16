extends Weapon

onready var reload_sound = preload("res://assets/sounds/weapon/sniper/reload.wav")
onready var shot_sound = preload("res://assets/sounds/weapon/sniper/shot.wav")

onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var scope_position = $scope_position

func _ready():
	audio_stream_player_3d.unit_size = Global.sound_amplified
	
func prepare_projectile():
	#.prepare_projectile()
	
	var last_index = get_tree().get_root().get_child_count() - 1
	
	for _i in 10:
		var bullet :Projectile = projectile.instance()
		bullet.speed = 36
		bullet.connect("reach", self , "on_bullet_reach_target")
		get_tree().get_root().get_child(last_index).add_child(bullet)
		_bullets.append(bullet)
		
		
func fire():
	if has_ammo():
		animation_player.play("fire")
		audio_stream_player_3d.stream = shot_sound
		audio_stream_player_3d.play()
	
	.fire()
	
func reload():
	.reload()
	
	if not can_reload():
		return
	
	if audio_stream_player_3d.playing:
		return
		
	audio_stream_player_3d.stream = reload_sound
	audio_stream_player_3d.play()
	
func add_weapon_mod(_mod :WeaponMod):
	.add_weapon_mod(_mod)
	
	if _mod.type_mod == WeaponMod.typeMod.scope:
		_mod.translation = scope_position.translation






