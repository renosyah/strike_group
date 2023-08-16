extends Node

onready var play = $SafeArea/VBoxContainer/CenterContainer/play

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("on_host_disconnected", self, "_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "_disconnected")
	NetworkLobbyManager.connect("on_host_ready", self, "_on_host_ready")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	play.visible = NetworkLobbyManager.is_server()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
		
func _disconnected():
	Global.change_scene("res://menu/main_menu/main_menu.tscn")

func _on_back_pressed():
	Network.disconnect_from_server()

# test
func _on_play_pressed():
	Global.change_scene("res://gameplay/mp/host/gameplay.tscn", false)
	
func _on_host_ready():
	Global.change_scene("res://gameplay/mp/client/gameplay.tscn", false)
	
	

