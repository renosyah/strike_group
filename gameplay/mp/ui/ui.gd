extends BaseGameplayUi

onready var huds = [
	$CanvasLayer/Control/crosshair,
	$CanvasLayer/Control/damage_direction,
	$CanvasLayer/Control/SafeArea
]

onready var crosshair = $CanvasLayer/Control/crosshair
onready var joystick = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer2/joystick

onready var cycle_weapon = $CanvasLayer/Control/SafeArea/buttons/left_group/cycle_weapon
onready var reload_button = $CanvasLayer/Control/SafeArea/buttons/right_group/reload
onready var retreat_button = $CanvasLayer/Control/SafeArea/buttons/left_group/retreat
onready var button_tween = $CanvasLayer/Control/SafeArea/buttons/button_tween

onready var compass = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer/compass
onready var target_info = $CanvasLayer/Control/SafeArea/VBoxContainer/MarginContainer/HBoxContainer/MarginContainer3/target_info
onready var menu = $CanvasLayer/Control/menu

onready var damage_direction = $CanvasLayer/Control/damage_direction

func _ready():
	menu.visible = false

func show_joystick(_val :bool):
	.show_joystick(_val)
	
	joystick.visible = _val

func get_joystick_output(basis :Basis) -> Vector3:
	var dir :Vector2 = joystick.get_output()
	return basis.z * dir.y + basis.x * dir.x

func set_crosshair_position(pos :Vector2):
	.set_crosshair_position(pos)
	
	crosshair.set_crosshair_position(pos)
	
func on_switch_infantry(info :InfantryInfo, unit :BaseUnit):
	.on_switch_infantry(info, unit)
	
	if unit is Infantry:
		var enable_reload :bool = is_instance_valid(unit.equiped_weapon)
		reload_button.disabled = not enable_reload
		reload_button.modulate.a = 1.0 if enable_reload else 0.5

func update_unit_weapon_info(unit : Infantry):
	.update_unit_weapon_info(unit)
	
	var weapon :Weapon = unit.equiped_weapon
	var is_weapon_equiped :bool = is_instance_valid(weapon)
	var is_item_equiped :bool = is_instance_valid(unit.equiped_item)
	
	crosshair.visible = (not unit.is_dead) and is_weapon_equiped and (not is_item_equiped) and (not menu.visible)
	
	var enable_reload :bool = (not unit.is_dead) and is_weapon_equiped
	reload_button.disabled = not enable_reload
	reload_button.modulate.a = 1.0 if enable_reload else 0.5
	
	if is_weapon_equiped:
		crosshair.show_reload_progress(weapon)
	
func update_player_target_info(data :InfantryData, unit :BaseUnit):
	.update_player_target_info(data, unit)
	
	target_info.update_infantry_info(data, unit)
	
func show_damage(_direction :Vector3):
	damage_direction.show_damage(_direction)
	
func enable_retreat_button(val :bool):
	.enable_retreat_button(val)
	
	retreat_button.disabled = not val
	retreat_button.modulate.a = 1.0 if val else 0.5
	
func update_compass(rotation :float, pos :Vector3, target :Vector3):
	.update_compass(rotation, pos, target)
	
	compass.rotation = rotation
	compass.current_position = pos
	compass.target_position = target
	
	damage_direction.current_y_rotation = rotation
	
func _on_reload_pressed():
	button_tween.interpolate_property(reload_button, "rect_scale", Vector2.ONE * 0.8, Vector2.ONE, 0.2)
	button_tween.start()
	on_reload()

func _on_retreat_pressed():
	button_tween.interpolate_property(retreat_button, "rect_scale", Vector2.ONE * 0.8, Vector2.ONE, 0.2)
	button_tween.start()
	on_retreat()
	
func _on_cycle_weapon_pressed():
	button_tween.interpolate_property(cycle_weapon, "rect_scale", Vector2.ONE * 0.8, Vector2.ONE, 0.2)
	button_tween.start()
	on_cycle_weapon()
	
func _on_menu_pressed():
	show_menu()
	
func show_menu():
	.show_menu()
	
	menu.visible = true
	
	for i in huds:
		i.visible = false

func _on_menu_on_resume_press():
	menu.visible = false
	
	for i in huds:
		i.visible = true
		
func _on_menu_on_main_menu_press():
	menu.visible = false
	on_main_menu()


















