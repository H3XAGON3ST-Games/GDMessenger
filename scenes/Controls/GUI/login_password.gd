extends Control

signal login_passed
signal finish_animated

func _ready():
	play_animation("RESET")
	yield($lp_animation, "animation_finished")
	play_animation("lp_on")

func play_animation(anim_name: String): 
	$lp_animation.play(anim_name)

func _on_lp_animation_finished(anim_name):
	match anim_name:
		"lp_on": 
			pass
		"lp_off": 
			if !Global.is_authorized:
				play_animation("lp_on")
				return
			emit_signal("finish_animated")


func _on_sign_pressed():
	Global.login = $input_login.text
	Global.password = $input_password.text
	
	if !(Global.login and Global.password):
		
		return
	
	emit_signal("login_passed")
