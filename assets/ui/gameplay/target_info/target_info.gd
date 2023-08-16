extends MarginContainer
class_name TargetInfo

onready var unit_name = $HBoxContainer/VBoxContainer/unit_name
onready var hp_bar = $HBoxContainer/VBoxContainer/hp_bar
onready var autohide_timer = $autohide_timer

func _ready():
	modulate.a = 0.0
	hp_bar.set_hp_bar_color(Color.red)

func _process(_delta):
	modulate.a = clamp(autohide_timer.time_left, 0, 1)

func update_infantry_info(data :InfantryData, unit :BaseUnit):
	unit_name.text = "Lvl %s %s" % [data.level, data.entity_name]
	hp_bar.update_bar(unit.hp, unit.max_hp)
	autohide_timer.start()
