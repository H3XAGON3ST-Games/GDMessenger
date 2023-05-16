extends Button

var nickname_text : String = "nickname test" setget set_nickname # Никнейм пользователя
var lmessage_text : String = "last message test" setget set_lmessage # Последнее сообщение


func set_nickname(value): 
	nickname_text = value

func set_lmessage(value):
	lmessage_text = value

func update():
	self.nickname_text
	self.lmessage_text
