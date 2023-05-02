extends Control

signal login_passed
signal finish_animated

var login
var password

func _ready():
	play_animation("lp_on")

func play_animation(anim_name: String): 
	$lp_animation.play(anim_name)

func _on_lp_animation_finished(anim_name):
	match anim_name:
		"lp_on": 
			pass
		"lp_off": 
			emit_signal("finish_animated")


func _on_sign_pressed():
	login = $input_login.text
	password = $input_password.text
	
	if !(login and password):
		
		return
	emit_signal("login_passed")
