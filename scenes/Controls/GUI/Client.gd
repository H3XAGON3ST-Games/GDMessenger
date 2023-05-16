extends Control
class_name Client

var _use_multiplayer = false
var _client = WebSocketClient.new()
var _write_mode = WebSocketPeer.WRITE_MODE_BINARY

var is_authorized : bool = false

func join_room() -> bool: 
	var supported_protocols = PoolStringArray(["my-protocol2", "my-protocol", "binary"])
	var err = _client.connect_to_url("localhost:2000", supported_protocols, false)
	if !err == OK:
		return false
	
	return true

func data_verification(nickname, password) -> bool:
	send_data("%s%s%s" % [nickname, Global.separator, password], 1)
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
	data_verification(Global.login, Global.password)


func _client_disconnected(clean=true):
	print("Client just disconnected. Was clean: %s" % clean)


func _client_received(_p_id = 1):
	if _use_multiplayer:
		var peer_id = _client.get_packet_peer()
		var packet = _client.get_packet()
		print("MPAPI: From %s Data: %s" % [str(peer_id), Global.decode_data(packet, false)])
	else:
		var packet = _client.get_peer(1).get_packet()
		var is_string = _client.get_peer(1).was_string_packet()
		print("Received data. BINARY: %s: %s" % [not is_string, Global.decode_data(packet, is_string)])


func connect_to_url(host, protocols, multiplayer):
	return _client.connect_to_url(host, protocols, multiplayer)


func disconnect_from_host():
	_client.disconnect_from_host(1000, "Bye bye!")


func send_data(data, dest):
	_client.get_peer(1).set_write_mode(_write_mode)
	_client.get_peer(1).put_packet(Global.encode_data(data, _write_mode))


func set_write_mode(mode):
	_write_mode = mode
