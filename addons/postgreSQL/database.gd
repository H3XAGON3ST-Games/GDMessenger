extends Node

var database := PostgreSQLClient.new()

var USER = Global.DB_USER
var PASSWORD = Global.DB_PASSWORD
var HOST = Global.DB_HOST
var PORT = Global.DB_PORT # Default postgres port
var DATABASE = Global.DB_DATABASE # Database name



func _init() -> void:
	var _error := database.connect("connection_established", self, "_executer")
	print(_error)
	_error = database.connect("authentication_error", self, "_authentication_error")
	print(_error)
	_error = database.connect("connection_closed", self, "_close")
	print(_error)
	#Connection to the database
	_error = database.connect_to_host("postgresql://%s:%s@%s:%d/%s" % [USER, PASSWORD, HOST, PORT, DATABASE])
	print(_error)

func _process_poll() -> void:
	database.poll()


func _authentication_error(error_object: Dictionary) -> void:
	prints("Error connection to database:", error_object["message"])


func _executer() -> void:
	print(database.parameter_status)
	# leave just in case
#	var datas := database.execute("""
#		CREATE TABLE "user" (
#			"login_nickname" varchar(60) PRIMARY KEY NOT NULL,
#			"password" varchar(60) NOT NULL
#		);
#	""")
#	var datas = database.execute("""SELECT get_user_data('h3xa');""")
	
#	#The datas variable contains an array of PostgreSQLQueryResult object.
#	for data in datas:
#		#Specifies the number of fields in a row (can be zero).
#		print(data.number_of_fields_in_a_row)
#
#		# This is usually a single word that identifies which SQL command was completed.
#		# note: the "BEGIN" and "COMMIT" commands return empty values
#		print(data.command_tag)
#
#		print(data.row_description)
#
#		print(data.data_row)
#
#		prints("Notice:", data.notice)
#
#	if not database.error_object.empty():
#		prints("Error:", database.error_object)
	
#	database.close() 


func get_user_password(nickname: String) -> String:
	var datas = database.execute("""SELECT get_user_data('""" + nickname + """');""")
	if datas[0].raw_data_row.empty():
		return "error_username_not_found"
	var datatext: String = datas[0].data_row[0][0].get_string_from_utf8().replace("(", "").replace(")", "")
	var password := datatext.split(",")[1]
	print(password)
	
	return password

func is_user_there(nickname: String) -> bool: 
	var datas = database.execute("""SELECT get_user_data('""" + nickname + """');""")
	if datas[0].raw_data_row.empty():
		return false
	return true

func set_user(nickname, password) -> bool:
	var datas = database.execute("""SELECT set_user_data('""" + nickname + """', '""" + password + """');""")
	
	if get_user_password(nickname) == "error_username_not_found":
		return false
	
	return true

func get_messages_from_chat(chat_id) -> Array: 
	var datas = database.execute("""
		SELECT id_user, "message_text" FROM chat_has_message 
		WHERE id_chat = '""" + str(chat_id) + "'")
	return datas[0].data_row

func set_message(nickname, chat_id, text): 
	var datas = database.execute("""
	SELECT set_message_text('""" + nickname + """', '""" + text + """', '""" + chat_id + """');""")

func get_chat_from_nicknames(nicknames: Array):
	var datas = database.execute("""
		SELECT user_has_chat.id_user, tchat.id_chat 
		FROM user_has_chat 
		JOIN (SELECT id_chat FROM get_user_chat_list('""" + nicknames[0] + """')) tchat on user_has_chat.id_chat = tchat.id_chat 
		WHERE user_has_chat.id_user != '""" + nicknames[0] + "' and user_has_chat.id_user = '" + nicknames[1] + "'")
	return datas[0].raw_data_row

func get_chat_list(nickname) -> Array:
	var datas = database.execute("""
		SELECT user_has_chat.id_user, tchat.id_chat 
		FROM user_has_chat 
		JOIN (SELECT id_chat FROM get_user_chat_list('""" + nickname + """')) tchat on user_has_chat.id_chat = tchat.id_chat 
		WHERE user_has_chat.id_user != '""" + nickname + "'")
	return datas[0].raw_data_row

func set_chat(chat_id, nicknames: Array):
	var datas = database.execute("""
		INSERT INTO chat 
		VALUES
		('%s', null); """ % [chat_id] + """
		INSERT INTO user_has_chat
		VALUES
		('%s', '%s'),
		('%s', '%s'); """ % [nicknames[0], chat_id, nicknames[1], chat_id]
		)
	print("""
		INSERT INTO chat 
		VALUES
		('%s', null) """ % [chat_id] + """
		INSERT INTO user_has_chat
		VALUES
		('%s', '%s'),
		('%s', '%s') """ % [nicknames[0], chat_id, nicknames[1], chat_id])

func _close(clean_closure := true) -> void:
	prints("DB CLOSE,", "Clean closure:", clean_closure)


func _exit() -> void:
	database.close()
