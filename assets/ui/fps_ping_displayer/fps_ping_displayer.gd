extends MarginContainer

enum Mode {DETAIL , SIMPLE }

export(Mode) var mode := Mode.DETAIL

onready var simple = $simple
onready var detail = $detail

onready var os = $detail/HBoxContainer9/os
onready var platform = $detail/HBoxContainer9/platform
onready var cpu = $detail/HBoxContainer8/cpu
onready var driver = $detail/HBoxContainer8/driver
onready var fps = $detail/HBoxContainer/fps
onready var drawn = $detail/HBoxContainer/drawn
onready var memory_usage = $detail/HBoxContainer2/memory_usage
onready var memory_peak = $detail/HBoxContainer2/memory_peak
onready var ping = $detail/HBoxContainer6/ping

onready var simple_fps = $simple/fps
onready var simple_ping = $simple/ping

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_mode()
	os.text = "Os : %s" % OS.get_model_name()
	platform.text = "Platform : %s" % OS.get_name()
	cpu.text = "Cpu : %s" % OS.get_processor_name()
	driver.text = "Driver : %s" % OS.get_video_driver_name(OS.get_current_video_driver())
	
	Network.connect("on_ping", self, "on_ping")
	
func _check_mode():
	if mode == Mode.SIMPLE:
		simple.visible = true
		detail.visible = false
		
	elif mode == Mode.DETAIL:
		simple.visible = false
		detail.visible = true
		
	
func on_ping(_ping :int):
	ping.text = "Ping : " + str(_ping) + "/ms"
	simple_ping.text = ping.text
	
func _process(_delta):
	fps.text = "Current : %s/Fps" % Engine.get_frames_per_second()
	drawn.text = "Objects : %s" % Performance.get_monitor(Performance.RENDER_OBJECTS_IN_FRAME)
	
	memory_usage.text = "Usage : %s" % format_size(OS.get_static_memory_usage())
	memory_peak.text = "Peak : %s" % format_size(OS.get_static_memory_peak_usage())
	
	simple_fps.text = "Fps : %s" % Engine.get_frames_per_second()
	
func format_size(size :int):
	var b :float = size
	var k :float = size/1024.0
	var m :float = ((size/1024.0)/1024.0)
	var g :float = (((size/1024.0)/1024.0)/1024.0)
	var t :float = ((((size/1024.0)/1024.0)/1024.0)/1024.0)

	if t > 1:
		return "%s TB" % t
	elif g > 1:
		return "%s GB" % g
	elif m > 1:
		return "%s MB" % m
	elif k > 1:
		return "%s KB" % k
		
	return "%s Bytes" % b
