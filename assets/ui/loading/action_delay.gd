extends MarginContainer

signal finish

onready var action_delay_label = $action_delay_label
onready var action_delay_progress = $action_delay_progress
onready var action_delay_timer = $action_delay_timer

func _ready():
	set_process(false)
	hide()
	
func is_progress():
	return not action_delay_timer.is_stopped()
	
func start(text :String ,wait_time :float):
	action_delay_label.text = text
	action_delay_timer.wait_time = wait_time 
	action_delay_timer.start()
	show()
	set_process(true)
	
func _process(_delta):
	action_delay_progress.value = action_delay_timer.time_left
	action_delay_progress.max_value = action_delay_timer.wait_time

func _on_action_delay_timer_timeout():
	hide()
	set_process(false)
	emit_signal("finish")








