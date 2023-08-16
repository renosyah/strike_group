extends Control

onready var timer = $Timer

var current_y_rotation :float
var current_angle :float

var _is_showing :bool = false
onready var animation_player = $AnimationPlayer
onready var damage_indicator = $damage_indicator
onready var dup_atlas :AtlasTexture = (damage_indicator.texture as AtlasTexture).duplicate()

func _ready():
	damage_indicator.texture = dup_atlas
	
	margin_bottom = 0.5
	margin_left = 0.5
	margin_right = 0.5
	margin_top = 0.5

func show_direction():
	if _is_showing:
		return
		
	_is_showing = true
	timer.start()
	animation_player.play("damage")
	
func is_showing() -> bool:
	return _is_showing
	
func _process(_delta):
	rect_rotation = current_angle + current_y_rotation

func _on_Timer_timeout():
	animation_player.play_backwards("damage")
	yield(animation_player,"animation_finished")
	_is_showing = false















