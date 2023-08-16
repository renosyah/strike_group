extends BaseCustomParticle
class_name CustomTextParticle

export var text :String

onready var _mesh :Mesh = mesh.duplicate()

func _ready():
	mesh = _mesh

func on_pre_emmit():
	.on_pre_emmit()
	
	if not mesh is TextMesh:
		return
		
	(mesh as TextMesh).text = text
	amount = int(rand_range(2, 4))
