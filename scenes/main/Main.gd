extends Node

var is_server : bool = Global.is_server

enum OVERRIDE_TYPE {
	DO_NOT_OVERRIDE,
	OVERRIDE_TRUE,
	OVERRIDE_FALSE
}

export(OVERRIDE_TYPE) var is_server_override : int = OVERRIDE_TYPE.DO_NOT_OVERRIDE

export var client_scene : PackedScene # Loaded client scene
export var server_scene : PackedScene # Loaded server scene

func _ready(): # Checking the condition for selecting the desired scene
	print(is_server_override)
	match is_server_override: 
		OVERRIDE_TYPE.DO_NOT_OVERRIDE:
			print("DO NOT OVERRIDE")
			if is_server: 
				add_scene(server_scene)
				return
			add_scene(client_scene)
		OVERRIDE_TYPE.OVERRIDE_TRUE:
			print("OVERRIDE SCENE FOR SERVER")
			add_scene(server_scene)
			Global.is_server = true
		OVERRIDE_TYPE.OVERRIDE_FALSE:
			print("OVERRIDE SCENE FOR CLIENT")
			add_scene(client_scene)
			Global.is_server = false
	

func add_scene(scene: PackedScene): # Adding a Scene to the Tree
	if scene == null:
		Global.save_and_exit()
		return
	add_child(scene.instance())
