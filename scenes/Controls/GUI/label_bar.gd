extends Control

var is_following: bool = false
var position: Vector2 = Vector2.ZERO

func _on_label_bar_gui_input(event):
	if event is InputEventMouseButton:
		if event.get_button_index() == 1:
			position = get_local_mouse_position()
			is_following = event.pressed
			print(position)
	
	if is_following:
		OS.set_window_position(OS.window_position + get_local_mouse_position() - position)



func _on_Button_pressed():
	Global.save_and_exit()
