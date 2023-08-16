extends MeshInstance
class_name Water

export var map_size :float = 200

func _ready():
	(mesh as PlaneMesh).size = Vector2.ONE * map_size
