extends Node

const version : String = "0.0.2"

var gui

#var gui_ready := false setget set_gui_ready
#func set_gui_ready(value):
#	gui_ready = value
#	gui = get_tree().get_root().get_node_or_null("GUI")
#	print(gui)



func _ready():
	pass

func save_data():
	print("save data")

func save_and_exit():
	save_data()
	get_tree().quit()
	
