extends HBoxContainer

signal animated_hide

onready var friends_container := $friends_menu/scroll_container/friends_container

const bchat = preload("res://scenes/Controls/ChatButton/bchat.tscn")

func play_animation(anim_name: String): 
	$main_animation.play(anim_name)


func _on_main_animation_finished(anim_name):
	match anim_name:
		"m_on": 
			pass
		"m_off": 
			emit_signal("animated_hide")


func add_friends_bchat(nickname, last_message):
	var bchat_intance = bchat.instance()
	if friends_container.get_node_or_null(nickname) != null:
		push_error(nickname + " already exists")
		return
	bchat_intance.name = nickname
	friends_container.add_child(bchat_intance)


func update_friends_bchat(nickname, last_message):
	var bchat_intance = friends_container.get_node_or_null(nickname)
	if (bchat_intance == null):
		return
	bchat_intance.update()

func del_friends_bchat():
	bchat
