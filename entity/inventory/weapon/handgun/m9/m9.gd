extends Weapon

onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var scope_position = $scope_position

func _ready():
	audio_stream_player_3d.unit_size = Global.sound_amplified

func fire():
	if has_ammo():
		animation_player.play("fire")
		audio_stream_player_3d.stream = preload("res://assets/sounds/weapon/handgun/shot.wav")
		audio_stream_player_3d.play()
		
	.fire()
	
func reload():
	.reload()
	
	if not can_reload():
		return
		
	audio_stream_player_3d.stream = preload("res://assets/sounds/weapon/handgun/reload.wav")
	audio_stream_player_3d.play()
	
func add_weapon_mod(_mod :WeaponMod):
	.add_weapon_mod(_mod)
	
	if _mod.type_mod == WeaponMod.typeMod.scope:
		_mod.translation = scope_position.translation
		_mod.scale = Vector3.ONE * 0.5



