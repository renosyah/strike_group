extends MarginContainer

signal pressed(item)

export var icon :Texture
export var title :String

var is_selected :bool

onready var tween = $Tween
onready var panel_3 = $Panel3
onready var texture_rect = $VBoxContainer5/TextureRect
onready var label = $VBoxContainer5/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.texture = icon
	label.text = title
	panel_3.visible = is_selected
	
func set_selected(val :bool):
	is_selected = val
	panel_3.visible = is_selected
	
func _on_Button_pressed():
	tween.interpolate_property(self,"rect_scale",Vector2.ONE * 0.8, Vector2.ONE, 0.2, Tween.TRANS_BOUNCE)
	tween.start()
	emit_signal("pressed", self)

