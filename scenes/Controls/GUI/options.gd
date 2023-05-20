extends Control

onready var theme_settings := $ScrollContainer/VBoxContainer/theme_settings

const color_list := {
	"Default" : Color("00000000"), 
	"Green" : Color("0003180b"), 
	"Blue" : Color("0002060e"), 
	"Purple" : Color("00100212")
}

func _ready():
	$Panel/version.text = "Version: " + Global.version
	_configure_theme_settings()
	$ScrollContainer/VBoxContainer/sip.text = Global.SERVER_IP
	$ScrollContainer/VBoxContainer/sport.text = str(Global.SERVER_PORT)

func _configure_theme_settings():
	theme_settings.add_item("Default", 0)
	theme_settings.add_item("Green", 1)
	theme_settings.add_item("Blue", 2)
	theme_settings.add_item("Purple", 3)


func _on_theme_settings_item_selected(index):
	var color = theme_settings.get_item_text(index)
	theme_settings.selected = index
	Global.theme = index
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
