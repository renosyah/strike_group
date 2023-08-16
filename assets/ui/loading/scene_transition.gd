extends CanvasLayer
class_name SceneTransision

export var index :int = 0
onready var animations :Array = [
	$transision_1/AnimationPlayer,
	$transision_2/AnimationPlayer
]

func change_scene(scene :String, auto_dismiss :bool = true):
	animations[index].play("show")
	
	yield(animations[index],"animation_finished")
	
	get_tree().change_scene(scene)
	yield(get_tree(),"idle_frame")
	
	if auto_dismiss:
		dismiss()
		
func dismiss():
	animations[index].play("unshow")
