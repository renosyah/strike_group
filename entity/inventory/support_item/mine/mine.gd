extends SupportItem

export var attack_damage :int = 245
export var mine_count :int = 5

onready var cooldown_timer = $cooldown_timer

var mines :Array = []
var mine_ready :int

func _prepare_mines():
	if not mines.empty():
		return
		
	var last_index = get_tree().get_root().get_child_count() - 1
	
	for _i in range(mine_count):
		var mine :PlantExplosive = preload("res://entity/plant_explosive/mine/mine_entity.tscn").instance()
		mine.player_id = player_id
		mine.attack_damage = attack_damage
		mine.is_master = is_master
		mine.team = team
		mine.connect("explode", self, "on_explode")
		get_tree().get_root().get_child(last_index).add_child(mine)
		mines.append(mine)
		mine_ready += 1
	
func _drop_mine(_at :Vector3):
	for i in mines:
		var mine :PlantExplosive = i
		if mine.is_deployed():
			continue
			
		mine.drop_mine(_at)
		mine_ready -= 1
		return
		
func use(_enable :bool):
	.use(_enable)
	
	_prepare_mines()
	
	if _enable:
		cooldown_timer.start()
		
	else:
		cooldown_timer.stop()
	
func _on_cooldown_timer_timeout():
	if mine_ready < 1:
		return
		
	_drop_mine(global_transform.origin + (-global_transform.basis.z * 1.5) + Vector3(0,2,0))
	cooldown_timer.start()
	
func on_explode(_mine :PlantExplosive):
	mine_ready += 1
	
func get_max_cooldown() -> float:
	return cooldown_timer.wait_time
	
func cooldown_remain() -> float:
	return cooldown_timer.time_left
 






