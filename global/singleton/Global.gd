extends Node

const version : String = "0.0.2"

var separator: = "@#/."
var SERVER_PORT: int = 2000
var SERVER_IP: String 

var gui

var login
var password

var is_authorized: bool = false
#var gui_ready := false setget set_gui_ready
#func set_gui_ready(value):
#	gui_ready = value
#	gui = get_tree().get_root().get_node_or_null("GUI")
#	print(gui)

func reload_app():
	get_tree().reload_current_scene()


func _ready():
	pass


func save_data():
	print("save data")


func save_and_exit():
	save_data()
	get_tree().quit()


func encode_data(data, mode):
	if mode == WebSocketPeer.WRITE_MODE_TEXT:
		return data.to_utf8()
	return var2bytes(data)


func decode_data(data, is_string):
	if is_string:
		return data.get_string_from_utf8()
	return bytes2var(data)
