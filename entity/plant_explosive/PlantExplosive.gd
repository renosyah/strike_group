extends KinematicBody
class_name PlantExplosive

signal explode(mine)

const explosions = [
	preload("res://assets/sounds/explosions/explosion_1.wav"),
	preload("res://assets/sounds/explosions/explosion_2.wav"),
	preload("res://assets/sounds/explosions/explosion_3.wav")
]

export var player_id :String

export var attack_damage :int = 120

var is_master :bool
var team :int

var _is_deployed :bool
var _is_set_off :bool

func explode():
	_is_set_off = true
	emit_signal("explode", self)
	
func _process(delta):
	var collide :KinematicCollision = move_and_collide(Vector3.DOWN * 9.8 * delta)
	if not is_instance_valid(collide):
		return
		
	if collide.collider is StaticBody:
		set_process(false)
		return
	
func drop_mine(_at :Vector3):
	_is_deployed = true
	set_process(true)
	
func reset_mine():
	_is_deployed = false
	_is_set_off = false
	set_process(false)
	
func is_deployed() -> bool:
	return _is_deployed

