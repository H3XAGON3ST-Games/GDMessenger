extends HBoxContainer

signal animated_hide

func play_animation(anim_name: String): 
	$main_animation.play(anim_name)


func _on_main_animation_finished(anim_name):
	match anim_name:
		"m_on": 
			pass
		"m_off": 
			emit_signal("animated_hide")

