extends HBoxContainer

signal animated_hide

onready var friends_container := $friends_menu/scroll_container/friends_container
onready var message_container := $chat/main_body/chat/ScrollContainer/VBoxContainer
onready var main_body := $chat/main_body

const bchat = preload("res://scenes/Controls/ChatButton/bchat.tscn")

func _ready():
	$chat/main_body.visible = false

func play_animation(anim_name: String): 
	$main_animation.play(anim_name)

func _on_main_animation_finished(anim_name):
	match anim_name:
		"m_on": 
			pass
		"m_off": 
			emit_signal("animated_hide")


func add_friends_bchat(nickname, id_chat, last_message = ""):
	var bchat_intance = bchat.instance()
	if friends_container.get_node_or_null(nickname) != null:
		push_error(nickname + " already exists")
		return
	bchat_intance.name = nickname
	bchat_intance.id_chat = id_chat
	bchat_intance.nickname_text = nickname
	bchat_intance.lmessage_text = last_message
	friends_container.add_child(bchat_intance)


func update_friends_bchat(nickname, last_message):
	var bchat_intance = friends_container.get_node_or_null(nickname)
	if (bchat_intance == null):
		return
	bchat_intance.lmessage_text = last_message

func del_all_friends_bchat():
	for node in friends_container.get_children():
		node.queue_free()

func del_all_message_text():
	for node in message_container.get_children():
		node.queue_free()

func set_disable_all_friends_bchat(value: bool):
	for node in friends_container.get_children():
		print(node, value)
		node.disabled = value

func set_top_chat_info(nickname, status):
	$chat/main_body/chat/top_chat/ichat.nickname_label.text = nickname
	$chat/main_body/chat/top_chat/ichat._change_status(status)


func _on_GUI_chat_list(name_chat, chat_id):
	add_friends_bchat(name_chat, chat_id)
