extends Control

const wounded_color = Color.orange
const dead_color = Color.red

onready var _tween = $Tween
onready var _texture_rect = $TextureRect
onready var _progress_bar = $ProgressBar

func _ready():
	hide_reviving_progress()

func show_wounded(expire_time :float):
	_tween.interpolate_property(
		_texture_rect, "self_modulate",
		wounded_color, dead_color,
		expire_time, Tween.TRANS_LINEAR
	)
	_tween.start()
	
func show_reviving_progress():
	_texture_rect.visible = false
	_progress_bar.visible = true
	
func hide_reviving_progress():
	_texture_rect.visible = true
	_progress_bar.visible = false
	
func reviving(time_left :float, wait_time :float):
	_progress_bar.max_value = wait_time
	_progress_bar.value = wait_time - time_left
