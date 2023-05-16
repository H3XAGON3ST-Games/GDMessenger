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
#	configure_client()

func configure_shortcut_esc():
	shortcut_esc.shortcut = InputEventAction.new()
	shortcut_esc.shortcut.action = "ui_esc"
	button_settings.shortcut = shortcut_esc

func set_authorize_state(state: bool): 
	is_authorized = state
	button_logout.disabled = !is_authorized

func set_visible_main_gui(value: bool) -> void: 
	login_password.visible = !value
	friends_menu.visible = value
	chat.visible = value 

func set_color(value: Color):
	$ColorRect.color = value

# После авторизации
# True для is_authorized и false для disabled у кнопки logout, проигрывание lp_off
# lp_off - скрытие login_password
func _on_login_password_authorized():
	set_authorize_state(true)
	login_password.play_animation("lp_off")
	Global.is_authorized = join_room()
	

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
	if is_authorized == false:
		return
	
	disconnect_from_host()
	main_container.play_animation("m_off")
	set_authorize_state(false)

# После проигрывания m_off, включение видимости элементов login_password
# Проигрывание lp_on
func _on_main_container_animated_hide():
	set_visible_main_gui(false)
	login_password.play_animation("lp_on")
# ---------------------------------------

var message := preload("res://scenes/Controls/message_text/message_text.tscn")
onready var message_container := $root_container/main_container/chat/main_body/chat/ScrollContainer/VBoxContainer
onready var input_text := $root_container/main_container/chat/main_body/input/input_text

var nickname_to_send: String = "h3xa"

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
	var send_message_data := "%s%s%s%s%s" % [nickname_to_send, Global.separator, "message", Global.separator, text]
	send_data(send_message_data, 1)

