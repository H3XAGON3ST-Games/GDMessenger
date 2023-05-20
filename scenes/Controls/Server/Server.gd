extends Control

onready var console := $console

var _server := WebSocketServer.new()
var _use_multiplayer = false
var _clients = {}
var _nickname_to_id = {}
var _write_mode = WebSocketPeer.WRITE_MODE_BINARY

func _init():
	_server.connect("client_connected", self, "_client_connected")
	_server.connect("client_disconnected", self, "_client_disconnected")
	_server.connect("client_close_request", self, "_client_close_request")
	
	_server.connect("data_received", self, "_client_receive")
	
	_server.connect("peer_packet", self, "_client_receive")
	_server.connect("peer_connected", self, "_client_connected", ["multiplayer_protocol"])
	_server.connect("peer_disconnected", self, "_client_disconnected")


const database := preload("res://addons/postgreSQL/database.gd")
var database_instance
# Конфигурация сервера 
func _ready():
	database_instance = database.new()
	
	OS.window_borderless = false
	
	var supported_protocols = PoolStringArray(["my-protocol", "binary"])
	listen(Global.SERVER_PORT, supported_protocols, _use_multiplayer)
	
	write_text("Server has been started on:")
	write_text(IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), IP.TYPE_IPV4) + ":" + str(Global.SERVER_PORT))

func _exit_tree():
	_server.stop()
	database_instance._exit()

# Прослушивание сервера с периодической частотой каждые max_count кадров
export(int, 1, 30) var max_count = 1
var count = 0
func _physics_process(_delta):
	count += 1
	if count >= max_count and _server.is_listening():
		_server.poll()
		database_instance._process_poll()
		count = 0
		print("poll")

# Функция конфигурации прослушивания сервера типа [порт, поддерживаемые протоколы, мультиплеер]
func listen(port, supported_protocols, multiplayer):
	_use_multiplayer = multiplayer
#	if _use_multiplayer:
#		set_write_mode(WebSocketPeer.WRITE_MODE_BINARY)
	return _server.listen(port, supported_protocols, _use_multiplayer)


# Работа с клиентом
func _client_close_request(id, code, reason):
	write_text("Client %s close code: %d, reason: %s" % [id, code, reason])

func _client_connected(id, protocol):
	_clients[id] = {"client" : _server.get_peer(id)}
	_clients[id]["has_data_received"] = false
	_clients[id]["nickname"] = ""
	_clients[id]["client"].set_write_mode(_write_mode)
	write_text("%s: Client connected with protocol %s" % [id, protocol])

func _client_disconnected(id, clean = true):
	write_text("Client %s disconnected. Was clean: %s" % [id, clean])
	if _clients.has(id):
		var nickname = _clients[id]["nickname"]
		_clients.erase(id)
		_nickname_to_id.erase(nickname)

func disconnect_client(id, text := "unauthorized"):
	var request = "%s%s%s" % ["", Global.separator, text]
	send_to_person(id, request)

func get_client_info(id):
	var packet = _server.get_peer(id).get_packet()
	var is_string = _server.get_peer(id).was_string_packet()
	var command_text = str(Global.decode_data(packet, is_string)).split(Global.separator)
	
	var command: String = command_text[0]
	
	match command:
		"login":
			var password = database_instance.get_user_password(command_text[1])
			if password == "error_username_not_found":
				disconnect_client(id)
				return
			
			if password != command_text[2]:
				disconnect_client(id)
				return
			
			_clients[id]["nickname"] = command_text[1]
			_clients[id]["has_data_received"] = true
			write_text(command_text[1])
			
			var request = "%s%s%s" % ["", Global.separator, "authorized"]
			
			send_to_person(id, request)
			
			_nickname_to_id[_clients[id]["nickname"]] = int(id)
		"signup":
			var password = database_instance.get_user_password(command_text[1])
			if password != "error_username_not_found" or command_text[2] == "error_username_not_found":
				disconnect_client(id)
				return
			
			if !database_instance.set_user(command_text[1], command_text[2]):
				disconnect_client(id)
				return
			
			_clients[id]["nickname"] = command_text[1]
			_clients[id]["has_data_received"] = true
			write_text("signup " + command_text[1])
			
			var request = "%s%s%s" % ["", Global.separator, "authorized"]
			send_to_person(id, request)
			_nickname_to_id[_clients[id]["nickname"]] = int(id)

func match_action(id):
	var packet = _server.get_peer(id).get_packet()
	var is_string = _server.get_peer(id).was_string_packet()
	var command_text = str(Global.decode_data(packet, is_string)).split(Global.separator) #1234@#/.message@#/.text
	var nickname_person = command_text[0]
	var action = command_text[1]
	match action: 
		"message":
			database_instance.set_message(_clients[id]["nickname"], command_text[3], command_text[2])
			var request = "%s%s%s%s%s" % [_clients[id]["nickname"], Global.separator, "message", Global.separator, command_text[2]]
			if _nickname_to_id.has(nickname_person) and _clients.has(id):
				send_to_person(_nickname_to_id[nickname_person], request)
				write_text("Data from %s (%s) to %s (%s) BINARY: %s: %s" % \
				[_clients[id]["nickname"], id, _clients[_nickname_to_id[nickname_person]]["nickname"],\
				_nickname_to_id[nickname_person], not is_string, request])
		"get_chat_list":
			var chat_list = database_instance.get_chat_list(_clients[id]["nickname"])
			var request: String = Global.separator + "chat_list" + Global.separator
			print(chat_list)
			
			var is_loop_skipped = true
			for chat in chat_list:
				request += "%s%s%s%s" % [chat[0], "┗┣┗", chat[1], "┓┫┓"]
				is_loop_skipped = false
			
			print(is_loop_skipped)
			if !is_loop_skipped: 
				request.erase(request.length() - 3, 3)
			
			print(request)
			send_to_person(id, request)
#			for user in user_has_chat:
#				for message in chat_has_message: # ┗┣┗     ┓┫┓
#					if message[1] == user[1]:
#						request += "%s%s%s%s%s" % []
#			request = "%s%s%s%s%s" % [_clients[id]["nickname"], Global.separator, "message", Global.separator, command_text[2]]
		"get_chat_data":
#			database_instance.get_chat_list("")
			var message_list = database_instance.get_messages_from_chat(command_text[2])
			var request: String = Global.separator + "chat_data" + Global.separator
			var is_loop_skipped = true
			for message in message_list:
				request += "%s%s%s%s" % [message[0], "┗┣┗", message[1], "┓┫┓"]
			request.erase(request.length() - 3, 3)
			if is_loop_skipped:
				request.erase(request.length() - 1, 1)
			print(request)
			send_to_person(id, request)
		"set_chat": 
			if !database_instance.is_user_there(nickname_person):
				print("user_not_found")
				return
			
			var nickname_list: Array = [_clients[id]["nickname"], nickname_person]
			var chat_list = database_instance.get_chat_from_nicknames(nickname_list)
			var request: String
			
			if chat_list.empty():
				request = Global.separator + "set_chat" + Global.separator
				
				var chat_id: String = _clients[id]["nickname"] + "_" + nickname_person
				
				database_instance.set_chat(chat_id, nickname_list)
				send_to_person(id, request + "%s%s%s" % [nickname_person, "┗┣┗", chat_id])
				send_to_person(nickname_person, request + "%s%s%s" % [_clients[id]["nickname"], "┗┣┗", chat_id])
				return
			print("user has a chat")

func send_to_person(id_person, data):
	if _clients.has(id_person):
		var person = _clients[id_person]["client"]
		_server.get_peer(id_person).put_packet(Global.encode_data(data, _write_mode))

func _client_receive(id):
	if !_clients[id]["has_data_received"]:
		get_client_info(id)
		return
	
	
	match_action(id)

func send_data(data, dest):
#	for id in _clients:
#		_server.get_peer(id["client"]).put_packet(Global.encode_data(data, _write_mode))
	pass

# Работа с консолью
func write_text(text):
	if console.text != "":
		console.text = console.text + '\n' + text 
		return
	console.text = text 



# create / kill
#func create__server():
#	yield(get_tree().create_timer(0.05), "timeout")
#	var _server := NetworkedMultiplayerENet.new()
#	_server.create__server(Global._server_PORT, 4095)
#	get_tree().set_network_peer(_server)
#
#	print(_server)
#
#func kill__server():
#	pass
# create / kill end

