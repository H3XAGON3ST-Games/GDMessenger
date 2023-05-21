extends Node

const version : String = "0.2.4-beta"

var is_server: bool

var separator: = "@#/."
var SERVER_PORT: int = 2000
var SERVER_IP: String 

var gui
var on_start_screen: bool = true
var theme: int

var login: String
var password: String
var variant_connect: String
var remember_me: bool

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


func _init():
	init_global_config()
	if is_server:
		init_server_config()


var DB_USER := "postgres"
var DB_PASSWORD := "04065665"
var DB_HOST := "localhost"
var DB_PORT := 5432 # Default postgres port
var DB_DATABASE := "gmessenger" # Database name

func init_server_config():
	var config = ConfigFile.new()
	var err = config.load("res://db_setting.cfg")
	if err == OK: 
		DB_USER = config.get_value("db_setting", "DB_USER")
		
		DB_PASSWORD = config.get_value("db_setting", "DB_PASSWORD")
		
		DB_HOST = config.get_value("db_setting", "DB_HOST")
		
		DB_PORT = config.get_value("db_setting", "DB_PORT")
		
		DB_DATABASE = config.get_value("db_setting", "DB_DATABASE_NAME")
	else: 
		config.set_value("db_setting", "DB_USER", DB_USER)
		
		config.set_value("db_setting", "DB_PASSWORD", DB_PASSWORD)
		
		config.set_value("db_setting", "DB_HOST", DB_HOST)
		
		config.set_value("db_setting", "DB_PORT", DB_PORT)
		
		config.set_value("db_setting", "DB_DATABASE_NAME", DB_DATABASE)
		config.save("res://db_setting.cfg")


func init_global_config():
	var config = ConfigFile.new()
	var err = config.load("res://setting.cfg")
	if err == OK: 
		is_server = config.get_value("global_setting", "is_server")
		
		login = config.get_value("client_data", "login")
		password = config.get_value("client_data", "password")
		remember_me = config.get_value("client_data", "remember_me")
		
		theme = config.get_value("client_setting", "theme", 0)
		SERVER_IP = config.get_value("client_setting", "ip")
		SERVER_PORT = config.get_value("client_setting", "port")
		
	else: 
		config.set_value("global_setting", "is_server", false)
		
		config.set_value("client_data", "login", "")
		config.set_value("client_data", "password", "")
		config.set_value("client_data", "remember_me", false)
		
		config.set_value("client_setting", "theme", 0)
		config.set_value("client_setting", "ip", "localhost")
		config.set_value("client_setting", "port", 2000)
		
		config.save("res://setting.cfg")
		is_server = false
		
		login = ""
		password = ""
		remember_me = false
		
		theme = 0
		SERVER_IP = "localhost"
		SERVER_PORT = 2000
		config.save("res://setting.cfg")


func save_data():
	var config = ConfigFile.new()
	var err = config.load("res://setting.cfg")
	if err == OK:
		config.set_value("global_setting", "is_server", is_server)
		
		if remember_me == true:
			config.set_value("client_data", "login", login)
			config.set_value("client_data", "password", password)
		else: 
			config.set_value("client_data", "login", "")
			config.set_value("client_data", "password", "")
		
		config.set_value("client_data", "remember_me", remember_me)
		
		config.set_value("client_setting", "theme", theme)
		config.set_value("client_setting", "ip", SERVER_IP)
		config.set_value("client_setting", "port", SERVER_PORT)
		
		config.save("res://setting.cfg")


func save_and_exit():
	save_data()
	yield(get_tree().create_timer(0.2), "timeout")
	get_tree().quit()


func encode_data(data, mode):
	if mode == WebSocketPeer.WRITE_MODE_TEXT:
		return data.to_utf8()
	return var2bytes(data)


func decode_data(data, is_string):
	if is_string:
		return data.get_string_from_utf8()
	return bytes2var(data)
