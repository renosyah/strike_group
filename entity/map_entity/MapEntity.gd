extends StaticBody
class_name MapEntity

const meshes :Array = [
	"res://entity/map_entity/bush_1/Bush1.obj",
	"res://entity/map_entity/bush_2/Bush2.obj",
	"res://entity/map_entity/bush_3/Bush3.obj",
	"res://entity/map_entity/rock_1/Rock1.obj",
	"res://entity/map_entity/rock_2/Rock2.obj",
	"res://entity/map_entity/rock_3/Rock3.obj",
	"res://entity/map_entity/tree_1/Tree1.obj",
	"res://entity/map_entity/tree_2/Tree2.obj",
	"res://entity/map_entity/tree_3/Tree3.obj",
	"res://entity/map_entity/tree_4/Tree4.obj"
]

static func get_random_mesh() -> String:
	return meshes[rand_range(0, meshes.size())]

export var mesh :Mesh
onready var mesh_instance = $MeshInstance

func _ready():
	mesh_instance.mesh = mesh
	
func _on_VisibilityNotifier_camera_entered(_camera):
	visible = true
	
func _on_VisibilityNotifier_camera_exited(_camera):
	visible = false

