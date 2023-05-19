extends Control

signal login_signup_passed
signal finish_animated

var unauthorized := false

func _ready():
	play_animation("RESET")
	yield($lp_animation, "animation_finished")
	play_animation("lp_on")

func play_animation(anim_name: String): 
#	if !Global.on_start_screen:
#		unauthorized = false
#		return
	$lp_animation.play(anim_name)

func _on_lp_animation_finished(anim_name):
	match anim_name:
		"lp_on": 
			Global.gui.set_authorize_state(false)
		"lp_off": 
#			Global.on_start_screen = false
			yield(get_tree().create_timer(5.0), "timeout")
			if Global.was_authorized:
				Global.was_authorized = false
				unauthorized = false
				return
			if !Global.is_authorized and !unauthorized:
#				_on_client_authorized(false)
				set_error_text("Timeout exceeded")
				print("unauth2", unauthorized)
			unauthorized = false


func set_data_to_global() -> bool:
	Global.login = $input_login.text
	Global.password = $input_password.text
	
	if !(Global.login and Global.password):
		return false
	return true

func _on_signin_pressed():
	if !set_data_to_global():
		return
	Global.variant_connect = "login"
	
	emit_signal("login_signup_passed")

func _on_signup_pressed():
	if !set_data_to_global():
		return
	Global.variant_connect = "signup"
	
	emit_signal("login_signup_passed")

func _on_client_authorized(boolean):
	Global.is_authorized = boolean
	print(boolean)
	if boolean:
		emit_signal("finish_animated")
		set_error_text("")
	else:
		play_animation("lp_on")
		get_parent()._client_disconnected()
		set_error_text("Server connection error")


func _on_client_unauthorized():
	unauthorized = true
	Global.is_authorized = false
	set_error_text("Invalid username or password")
	print("unauth1", unauthorized)
	get_parent()._client_disconnected()

onready var error_text := $back/error
func set_error_text(text = ""):
	error_text.text = text

