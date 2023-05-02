extends Control

onready var theme_settings := $ScrollContainer/VBoxContainer/theme_settings

const color_list := {
	"Default" : Color("00000000"), 
	"Green" : Color("331e492c"), 
	"Blue" : Color("331e4149"), 
	"Purple" : Color("332d1e49"), 
	"Dark" : Color("ae000000")
}

func _ready():
	_configure_theme_settings()

func _configure_theme_settings():
	theme_settings.add_item("Default", 0)
	theme_settings.add_item("Green", 1)
	theme_settings.add_item("Blue", 2)
	theme_settings.add_item("Purple", 3)
	theme_settings.add_item("Dark", 4)


func _on_theme_settings_item_selected(index):
	var color = theme_settings.get_item_text(index)
	Global.gui.set_color(color_list[color])

func play_animation(anim_name: String): 
	$o_animation.play(anim_name)

func _on_button_settings_toggled(button_pressed):
	if button_pressed == true: 
		play_animation("on")
		Global.gui.is_on_menu = true
	else:
		play_animation("off")
		Global.gui.is_on_menu = false
