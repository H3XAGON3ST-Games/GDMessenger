extends Label
class_name ichat

onready var status_label = $status
onready var nickname_label = $nickname

enum ICHAT_STATUS {
	ONLINE, 
	OFFLINE,
	DO_NOT_DISTURB
}

func _ready():
	pass


func _change_status(status):
	match status:
		ICHAT_STATUS.ONLINE: 
			status_label.text = "Online"
		ICHAT_STATUS.OFFLINE: 
			status_label.text = "Offline"
		ICHAT_STATUS.DO_NOT_DISTURB: 
			status_label.text = "Do not disturb"
