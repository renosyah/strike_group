extends Projectile

const explosions = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

onready var explosion_1 = $Explosion1
onready var explosion_timeout = $explosion_timeout
onready var body = $body
onready var sound = $AudioStreamPlayer3D

var _trajectory :Vector3
var _trajectory_target :Vector3

func _ready():
	sound.unit_size = Global.sound_amplified
	visible = false
	
func copy_mesh(mesh :MeshInstance):
	body.add_child(mesh.duplicate())

func projectile_travel(delta):
	if _trajectory.distance_to(_trajectory_target) > margin:
		_trajectory += Vector3.DOWN * speed * delta
		
	_direction = _get_pos().direction_to(_trajectory)
	
	if _get_pos().distance_to(_trajectory) < margin:
		_reach()
		_launching = false
		projectile_dismiss()
		set_process(false)
		
	.projectile_travel(delta)
	
func launch():
	.launch()
	
	body.visible = true
	visible = true
	
	var _target_pos :Vector3 = target.global_transform.origin
	var _height :float = _get_pos().distance_to(_target_pos)
	_trajectory_target = _target_pos
	_trajectory = _trajectory_target + Vector3(0, _height, 0)
	
func projectile_dismiss():
	.projectile_dismiss()
	
	body.visible = false
	explosion_1.emitting = true
	
	sound.stream = explosions[rand_range(0, explosions.size())]
	sound.play()
	
	explosion_timeout.start()
	
	# prevent being used
	_launching = true
	
func _on_explosion_timeout_timeout():
	visible = false
	
	# recycle after explode
	_launching = false



	





