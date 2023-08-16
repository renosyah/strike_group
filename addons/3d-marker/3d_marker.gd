extends Spatial
class_name ScreenMarker

enum Mode {
	show_offscreen
	show_onscreen
	show_always
}

export var camera :NodePath
export var icon : Texture = preload("res://addons/3d-marker/empty.png")
export var color : Color = Color.white
export(Mode) var mode := Mode.show_offscreen
export(Vector2) var screen_border_offset = Vector2( 80.0, 180.0 )

onready var _marker_item :Sprite = $marker_item
onready var _target_node: Spatial = get_parent()
onready var _current_camera: Camera = get_node_or_null(camera)

func _ready():
	if icon:
		_marker_item.set_marker(icon, color)
		
	_marker_item.visible = false
	
	var rect = _marker_item.get_rect().size
	if screen_border_offset.x < rect.x:
		screen_border_offset.x = rect.x
		
	if screen_border_offset.y < rect.y:
		screen_border_offset.y = rect.y
		
func _process(delta):
	if not is_instance_valid(_target_node):
		return
		
	if not is_instance_valid(_current_camera):
		return
		
	var pos :Vector3 = global_transform.origin
	var viewport_rect = _marker_item.get_viewport_rect()
	var target_2d_position: Vector2 = _current_camera.unproject_position(pos)
	var is_front_camera :bool = not _current_camera.is_position_behind(pos)
	var has_point :bool = viewport_rect.has_point(target_2d_position)
	
	_marker_item.position.x = clamp(target_2d_position.x, screen_border_offset.x, viewport_rect.size.x - screen_border_offset.x)
	_marker_item.position.y = clamp(target_2d_position.y, screen_border_offset.y, viewport_rect.size.y - screen_border_offset.y)
	_marker_item.look_at(target_2d_position)
	
	match (mode):
		Mode.show_offscreen:
			_marker_item.visible = not has_point and is_front_camera
			
		Mode.show_onscreen:
			_marker_item.visible = has_point and is_front_camera
			
		Mode.show_always:
			_marker_item.visible = true
 














