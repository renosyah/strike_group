extends Weapon

const bursh = [
	preload("res://assets/sounds/weapon/rifle/rifle_bursh.wav"),
	preload("res://assets/sounds/weapon/rifle/rifle_bursh_2.wav"), 
	preload("res://assets/sounds/weapon/rifle/rifle_bursh_3.wav")
]

onready var reload_sound = preload("res://assets/sounds/weapon/rifle/reload.wav")

onready var animation_player = $AnimationPlayer
onready var audio_stream_player_3d = $AudioStreamPlayer3D
onready var scope_position = $scope_position
onready var bursh_timer = $bursh_timer

func _ready():
	audio_stream_player_3d.unit_size = Global.sound_amplified

func fire():
	audio_stream_player_3d.stream = bursh[rand_range(0, bursh.size())]
	audio_stream_player_3d.play()
	
	for _i in range(3):
		if has_ammo():
			animation_player.play("fire")
		
		.fire()
		
		bursh_timer.start()
		yield(bursh_timer, "timeout")
		
func reload():
	.reload()
	
	if not can_reload():
		return
	
	audio_stream_player_3d.stream = reload_sound
	audio_stream_player_3d.play()

func add_weapon_mod(_mod :WeaponMod):
	.add_weapon_mod(_mod)
	
	if _mod.type_mod == WeaponMod.typeMod.scope:
		_mod.translation = scope_position.translation






