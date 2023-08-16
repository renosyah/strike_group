extends MarginContainer

onready var _hp_bar = $hp_bar
onready var _hp_bar_bg = $hp_bar_bg
onready var _label = $RichTextLabel

func _ready():
	_hp_bar.max_value = 100
	_hp_bar.value = 100
	
func show_label(_show = true):
	_label.visible = _show
	
func set_hp_bar_color(_color : Color):
	_hp_bar.tint_progress = _color
	
func _process(delta):
	_hp_bar_bg.max_value = _hp_bar.max_value
	_hp_bar_bg.value = lerp(_hp_bar_bg.value, _hp_bar.value, 5 * delta)
	
func update_bar(hp :int, max_hp :int):
	_hp_bar.max_value = float(max_hp)
	_hp_bar.value = clamp(float(hp), 0, max_hp)
	_label.text = "%s/%s" % [_hp_bar.value, _hp_bar.max_value]
	
