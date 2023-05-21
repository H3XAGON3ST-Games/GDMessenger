extends Control
class_name Client

var _use_multiplayer = false
var _client = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_BINARY

func connect_to_server(): 
	var supported_protocols = PoolStringArray(["TCP"])
	var err = _client.connect_to_url(Global.SERVER_IP + ":" + str(Global.SERVER_PORT), supported_protocols, false)
	if !err == OK:
		emit_signal("authorized", false)

func data_verification(nickname: String, password: String, variation: String) -> bool:
	send_data("%s%s%s%s%s" % [variation, Global.separator, nickname, Global.separator, password], 1)
	return false

func _init():
	_client.connect("connection_established", self, "_client_connected")
	_client.connect("connection_error", self, "_client_disconnected")
	_client.connect("connection_closed", self, "_client_disconnected")
	_client.connect("server_close_request", self, "_client_close_request")
	_client.connect("data_received", self, "_client_received")

	_client.connect("peer_packet", self, "_client_received")
	_client.connect("peer_connected", self, "_peer_connected")
	_client.connect("connection_succeeded", self, "_client_connected", ["multiplayer_protocol"])
	_client.connect("connection_failed", self, "_client_disconnected")

export(int, 1, 30) var max_count = 1
var count = 0
func _physics_process(_delta):
	count += 1
	if count >= max_count and !_client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		_client.poll()
		count = 0
		

func _client_close_request(code, reason):
	print("Close code: %d, reason: %s" % [code, reason])


func _peer_connected(id):
	print("%s: Client just connected" % id)



func _exit_tree():
	_client.disconnect_from_host(1001, "Bye bye!")


func _client_connected(protocol):
	print("Client just connected with protocol: %s" % protocol)
	_client.get_peer(1).set_write_mode(_write_mode)
	data_verification(Global.login, Global.password, Global.variant_connect)

signal disconnected
func _client_disconnected(clean=true):
	print("Client just disconnected. Was clean: %s" % clean)
	emit_signal("disconnected")


signal message(nickname, text)
signal authorized(boolean)
signal unauthorized()
signal chat_list(name_chat, chat_id)
signal message_list(id_user, message_text)
func match_action(text: String):
	var command_text = text.split(Global.separator)
	
	var nickname_person = command_text[0]
	var action = command_text[1]
	match action: 
		"message":
			if nickname_person == Global.username_state:
				emit_signal("message", nickname_person, command_text[2])
		"authorized":
			emit_signal("authorized", true)
			send_data(Global.separator + "get_chat_list", 1)
			Global.was_authorized = true
		"unauthorized":
			emit_signal("unauthorized")
		"chat_data":
			Global.gui.main_container.set_disable_all_friends_bchat(false)
			var message_list: PoolStringArray = command_text[2].split("┓┫┓")
			for elements in message_list:
				if elements.empty(): 
					return
				var message: PoolStringArray = elements.split("┗┣┗")
				print(message)
				emit_signal("message_list", message[0], message[1])
		"chat_list":
			var chat_list: PoolStringArray = command_text[2].split("┓┫┓")
			for elements in chat_list:
				var chat: PoolStringArray = elements.split("┗┣┗")
				emit_signal("chat_list", chat[0], chat[1])
		"set_chat":
			var chat: PoolStringArray = command_text[2].split("┗┣┗")
			emit_signal("chat_list", chat[0], chat[1])
			


func _client_received(_p_id = 1):
	var packet = _client.get_peer(1).get_packet()
	var is_string = _client.get_peer(1).was_string_packet()
	
	var data_text = Global.decode_data(packet, is_string)
	self.match_action(data_text)
	
	
	print("Received data. BINARY: %s: %s" % [not is_string, Global.decode_data(packet, is_string)])


func connect_to_url(host, protocols, multiplayer):
	return _client.connect_to_url(host, protocols, multiplayer)

signal host_shutdown
func disconnect_from_host():
	_client.disconnect_from_host(1000, "Bye bye!")
	emit_signal("host_shutdown")


func send_data(data, dest = 1):
	_client.get_peer(1).set_write_mode(_write_mode)
	_client.get_peer(1).put_packet(Global.encode_data(data, _write_mode))


func set_write_mode(mode):
	_write_mode = mode
