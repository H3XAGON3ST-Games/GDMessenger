extends Button

export var nickname_text : String = "" setget set_nickname # User nickname
export var lmessage_text : String = "" setget set_lmessage # Last message
var id_chat : String = ""

func set_nickname(value): 
	nickname_text = value
	$nickname.text = value

func set_lmessage(value):
	lmessage_text = value
	$last_message.text = value

func update():
	self.nickname_text
	self.lmessage_text


func _on_bchat_pressed():
	Global.set_username_state(nickname_text, id_chat)
