extends Control

export var color :Color = Color.red

onready var _border = $border
onready var _animation_player= $AnimationPlayer
onready var _is_hurting :bool = false

func _ready():
	_border.self_modulate = color
	_border.modulate.a = 0.0
	
func hide_hurt():
	if not _is_hurting:
		return
		
	_animation_player.stop(true)
	_border.modulate.a = 0.0
	
func show_hurt():
	if _animation_player.is_playing():
		return
		
	_animation_player.play("hurt")
	
func show_hurting():
	if _animation_player.is_playing() or _is_hurting:
		return
		
	_is_hurting = true
	_animation_player.play("hurting")
