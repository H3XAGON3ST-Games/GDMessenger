extends Control

onready var login_password := $login_password
onready var friends_menu := $"%friends_menu"
onready var chat := $"%chat"

onready var root_container := $root_container
onready var main_container := $root_container/main_container

onready var button_logout := $root_container/main_container/functional_menu/back/button_logout

var is_authorized : bool = false
var is_login_animated : bool = false
var is_main_animated : bool = false

func _ready():
	set_visible_main_gui(false)
	button_logout.disabled = true

func set_authorize_state(state: bool): 
	is_authorized = state
	button_logout.disabled = !is_authorized

func set_visible_main_gui(value: bool) -> void: 
	login_password.visible = !value
	friends_menu.visible = value
	chat.visible = value 

# После авторизации
# True для is_authorized и false для disabled у кнопки logout, проигрывание lp_off
# lp_off - скрытие login_password
func _on_login_password_authorized():
	set_authorize_state(true)
	
	login_password.play_animation("lp_off")

# После проигрывания lp_off, включение видимости main элементов, проигрывание m_on
# m_on - проявление элементов main
func _on_login_password_animated():
	set_visible_main_gui(is_authorized)
	main_container.play_animation("m_on")
# ---------------------------------------

# После нажатия на logout
# Обработка кнопки, проигрывание m_off
# False для is_authorized и true для disabled у кнопки logout
func _on_button_logout_pressed():
	if is_authorized == false:
		return
	
	main_container.play_animation("m_off")
	set_authorize_state(false)

# После проигрывания m_off, включение видимости элементов login_password
# Проигрывание lp_on
func _on_main_container_animated_hide():
	set_visible_main_gui(is_authorized)
	login_password.play_animation("lp_on")
# ---------------------------------------




