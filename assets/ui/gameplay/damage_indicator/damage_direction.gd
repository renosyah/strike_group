extends Control
class_name DamageDirection

export var max_indicator :int = 5
export var current_y_rotation :float

var indicators = []
var _last_direction :Vector3

func _ready():
	for _i in range(max_indicator):
		var p = preload("res://assets/ui/gameplay/damage_indicator/pivot.tscn").instance()
		add_child(p)
		indicators.append(p)

func show_damage(_direction :Vector3):
	if _last_direction.is_equal_approx(_direction):
		return
		
	_last_direction = _direction
	
	var dir_v2 :Vector2 = Vector2(_direction.x, _direction.z)
	var pos_from :Vector2 = rect_global_position + (dir_v2 * 10)
	var angle :float = rect_global_position.angle_to_point(pos_from)
	
	_show_pivot(rad2deg(angle))
	
func _process(_delta):
	for i in indicators:
		if i.is_showing():
			i.current_y_rotation = current_y_rotation
	
func _show_pivot(angle :float):
	for i in indicators:
		if not i.is_showing():
			i.current_angle = angle
			i.show_direction()
			return








