extends Node

const version : String = "0.1.0"

var separator: = "@#/."
var SERVER_PORT: int = 2000
var SERVER_IP: String 

var gui
var on_start_screen: bool = true

var login: String
var password: String
var variant_connect: String

var was_authorized: bool = false
var is_authorized: bool = false

var username_state: String = "none"
var id_chat_state: String
func set_username_state(nickname, id_chat):
	if username_state == nickname: 
		return
	
	username_state = nickname
	if username_state == "none":
		gui.main_container.main_body.visible = false
		return
	
	id_chat_state = id_chat
	gui.main_container.set_disable_all_friends_bchat(true)
	gui.main_container.del_all_message_text()
	gui.main_container.main_body.visible = true
	gui.main_container.set_top_chat_info(nickname, ichat.ICHAT_STATUS.OFFLINE)
	gui.send_data(separator + "get_chat_data" + separator + id_chat, 1)
	gui.nickname_to_send = nickname
	
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
