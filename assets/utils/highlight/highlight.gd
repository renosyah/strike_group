extends MeshInstance
class_name Highlight

export var highlight_color :Color

var unit :BaseUnit

onready var _highlight :SpatialMaterial = get_surface_material(0).duplicate()
onready var _non_highlight :SpatialMaterial = get_surface_material(0).duplicate()

func _ready():
	_highlight.albedo_color = highlight_color
	
	var color_unselected :Color = highlight_color
	color_unselected.a = 0.4
	
	_non_highlight.albedo_color = color_unselected
	set_surface_material(0, _non_highlight)
	
func highlight(val :bool):
	set_surface_material(0, _highlight if val else _non_highlight)

func _process(_delta):
	if not is_instance_valid(unit):
		return
		
	visible = not unit.is_dead
	if not visible:
		return
		
	translation = unit.global_transform.origin - Vector3(0,0.7,0)
	var look_direction :Vector3 = translation + -unit.global_transform.basis.z * Vector3(1,0,1) * 10
	
	if unit.face_direction.length() > 0.2:
		look_direction = translation + unit.face_direction * Vector3(1,0,1) * 10
		
	look_at(look_direction, Vector3.UP)






