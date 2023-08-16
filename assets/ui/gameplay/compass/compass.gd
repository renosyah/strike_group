extends MarginContainer
class_name Compass

export var rotation :float
export var current_position :Vector3
export var target_position :Vector3

onready var arrow = $VBoxContainer/MarginContainer/Control2/arrow
onready var bearing = $VBoxContainer/bearing
onready var distance = $VBoxContainer/distance
onready var inner_ring = $VBoxContainer/MarginContainer/Control2/inner_ring
onready var num = [
	$VBoxContainer/MarginContainer/Control2/inner_ring/n,
	$VBoxContainer/MarginContainer/Control2/inner_ring/w,
	$VBoxContainer/MarginContainer/Control2/inner_ring/e,
	$VBoxContainer/MarginContainer/Control2/inner_ring/s
]

func _ready():
	inner_ring.rect_pivot_offset = inner_ring.rect_size / 2

func _process(delta):
	inner_ring.rect_rotation = lerp(inner_ring.rect_rotation, rotation, 1 * delta)
	bearing.text = "%s \u00B0" % abs((int(inner_ring.rect_rotation) + 360) % 360)
	
	
	var pos :Vector2 = Vector2(current_position.x, current_position.z)
	var target :Vector2 = Vector2(target_position.x, target_position.z)
	distance.text = "%s m" % int(pos.distance_to(target))
	
	var angle :float = rad2deg(pos.angle_to_point(target)) + rotation
	arrow.rect_rotation = lerp(arrow.rect_rotation, angle, 1 * delta)
	
	for i in num:
		i.rect_rotation = -inner_ring.rect_rotation
		
	








