extends Client

onready var info_text := $"%info_text"

onready var login_password := $login_password
onready var friends_menu := $"%friends_menu"
onready var chat := $"%chat"

onready var options := $options

onready var root_container := $root_container
onready var main_container := $root_container/main_container

onready var button_logout := $root_container/main_container/functional_menu/back/button_logout
onready var button_settings := $"%button_settings"

onready var shortcut_esc := ShortCut.new()



var is_on_menu : bool = false setget set_menu_state
func set_menu_state(value):
	is_on_menu = value
	if value == true or value == false:
		button_settings.shortcut = shortcut_esc
		return
	button_settings.shortcut = null

func _ready():
	set_visible_main_gui(false)
	options.visible = false
	button_logout.disabled = true
	configure_shortcut_esc()
	
	info_text.text = "Messenger"
	
	Global.gui = self
	
	options._on_theme_settings_item_selected(Global.theme)
#	configure_client()

func configure_shortcut_esc():
	shortcut_esc.shortcut = InputEventAction.new()
	shortcut_esc.shortcut.action = "ui_esc"
	button_settings.shortcut = shortcut_esc

func set_authorize_state(state: bool): 
	Global.is_authorized = state
	button_logout.disabled = !state

func set_visible_main_gui(value: bool) -> void: 
	login_password.visible = !value
	friends_menu.visible = value
	chat.visible = value 

func set_color(value: Color):
	$ColorRect.color = value

# После авторизации
# True для is_authorized и false для disabled у кнопки logout, проигрывание lp_off
# lp_off - скрытие login_password
func _on_login_signup_passed():
	login_password.play_animation("lp_off")
	Global.SERVER_IP = $"%sip".text
	Global.SERVER_PORT = $"%sport".text
	connect_to_server()

# После проигрывания lp_off, включение видимости main элементов, проигрывание m_on
# m_on - проявление элементов main
func _on_login_password_animated():
	set_visible_main_gui(true)
	main_container.play_animation("m_on")
	info_text.text = str(Global.login) + " : Messenger"
# ---------------------------------------

# После нажатия на logout
# Обработка кнопки, проигрывание m_off
# False для is_authorized и true для disabled у кнопки logout
func _on_button_logout_pressed():
	if Global.is_authorized == false:
		return
	
	
	main_container.play_animation("m_off")
	disconnecting()

func _on_GUI_authorized(boolean):
	set_authorize_state(true)

# После проигрывания m_off, включение видимости элементов login_password
# Проигрывание lp_on
func _on_main_container_animated_hide():
	set_visible_main_gui(false)
	main_container.del_all_friends_bchat()
	main_container.get_node("chat/main_body").visible = false
	login_password.signup.disabled = false
	login_password.play_animation("lp_on")

func disconnecting():
	disconnect_from_host()
	set_authorize_state(false)
	info_text.text = "Messenger"

func _on_client_disconnected():
	disconnecting()

func _on_host_shutdown():
	set_authorize_state(false)
	main_container.play_animation("m_off")
# ---------------------------------------

var message := preload("res://scenes/Controls/message_text/message_text.tscn")
onready var message_container := $root_container/main_container/chat/main_body/chat/ScrollContainer/VBoxContainer
onready var input_text := $root_container/main_container/chat/main_body/input/input_text

var nickname_to_send: String = "h3xa"

func _on_GUI_message(nickname, text):
	create_message(text, Message.MESSAGE_VARIANT.FOR_CLIENT)

func create_message(text: String, message_variant: int):
	var current_message := message.instance()
	current_message.mtext = text
	current_message.message_variant = message_variant
	message_container.add_child(current_message)


func _on_Button_pressed():
	var text: String = input_text.text
	if text.length() == 0:
		return
	input_text.clear()
	create_message(text, Message.MESSAGE_VARIANT.FROM_CLIENT)
	var send_message_data := "%s%s%s%s%s%s%s" % [nickname_to_send, Global.separator, "message",\
	Global.separator, text, Global.separator, Global.id_chat_state]
	
	send_data(send_message_data, 1)


func _on_input_text_text_entered(new_text):
	_on_Button_pressed()

func _on_GUI_message_list(id_user, message_text):
	if Global.login == id_user:
		create_message(message_text, Message.MESSAGE_VARIANT.FROM_CLIENT)
		return
	create_message(message_text, Message.MESSAGE_VARIANT.FOR_CLIENT)


func _on_add_chat_text_entered(new_text):
	var send_message_data := "%s%s%s" % [new_text, Global.separator, "set_chat"]
	send_data(send_message_data)
	$root_container/main_container/friends_menu/back/add_chat.text = ""

func _on_enter_pressed():
	_on_add_chat_text_entered($root_container/main_container/friends_menu/back/add_chat.text)
