extends Control
class_name Crosshair

onready var reload_progress = $reload_progress
onready var crosshair_image = $crosshair_image

func set_crosshair_position(pos :Vector2):
	rect_position = pos  - (rect_size / 2)
	
func show_reload_progress(weapon :Weapon):
	reload_progress.visible = weapon.is_reloading()
	crosshair_image.visible = not reload_progress.visible
	reload_progress.value = weapon.reload_time_left()
	reload_progress.max_value = weapon.reload_delay
