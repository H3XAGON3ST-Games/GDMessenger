extends Label
class_name Message

enum MESSAGE_VARIANT {
	FROM_CLIENT, 
	FOR_CLIENT
}

export(MESSAGE_VARIANT) var message_variant = MESSAGE_VARIANT.FROM_CLIENT
export var mtext = ""

var from_client_style := preload("res://scenes/Controls/message_text/from_client.tres")
var for_client_style := preload("res://scenes/Controls/message_text/for_client.tres")

func _ready():
	if message_variant == MESSAGE_VARIANT.FROM_CLIENT:
		align = Label.ALIGN_RIGHT
		add_stylebox_override("normal", from_client_style)
	elif message_variant == MESSAGE_VARIANT.FOR_CLIENT:
		align = Label.ALIGN_LEFT
		add_stylebox_override("normal", for_client_style)
	
	self.text = mtext
