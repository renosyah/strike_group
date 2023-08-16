extends PlantExplosive

onready var mesh_instance = $MeshInstance
onready var damage_area = $damage_area
onready var mine_collision_shape = $CollisionShape
onready var mine_audio = $AudioStreamPlayer3D
onready var explosion_1 = $Explosion1

func _ready():
	reset_mine()
	explosion_1.set_as_toplevel(true)

func _on_damage_area_body_entered(body):
	if not _is_deployed:
		return
		
	if _is_set_off:
		return
		
	if body == self:
		return
		
	if not body is BaseUnit:
		return
		
	if body.team == team:
		return
		
	if body.is_dead:
		return
		
	explode()
	
	
func explode():
	yield(get_tree().create_timer(0.4), "timeout")
	
	mine_audio.stream = explosions[rand_range(0, explosions.size())]
	mine_audio.play()
	
	if is_master:
		var targets :Array = _get_unit_in_area()
		for i in targets:
			var unit :BaseUnit = i
			var unit_pos :Vector3 = unit.global_transform.origin
			var dir :Vector3 = global_transform.origin.direction_to(unit_pos)
			unit.take_damage(attack_damage, dir, player_id)
			
	explosion_1.translation = global_transform.origin
	explosion_1.emitting = true
	
	yield(get_tree(), "idle_frame")
	
	reset_mine()
	
	.explode()
	
func _get_unit_in_area() -> Array:
	var _units :Array = []
	for body in damage_area.get_overlapping_bodies():
		if body is BaseUnit:
			if body.is_dead:
				continue
				
			_units.append(body)
			
	return _units
	
func drop_mine(_at :Vector3):
	.drop_mine(_at)
	
	mesh_instance.visible = is_master
	translation = _at
	damage_area.set_deferred("monitoring", true)
	mine_collision_shape.set_deferred("disabled", false)
	
func reset_mine():
	.reset_mine()
	
	mesh_instance.visible = false
	translation = Vector3.ZERO
	damage_area.set_deferred("monitoring", false)
	mine_collision_shape.set_deferred("disabled", true)









