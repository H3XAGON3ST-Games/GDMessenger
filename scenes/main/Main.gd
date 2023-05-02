extends Node

export var is_server : bool = false

export var client_scene : PackedScene # Загруженная сцена клиента
export var server_scene : PackedScene # Загруженная сцена сервера

func _ready(): # Проверка условия для выбора нужной сцены
	if is_server: 
		add_scene(server_scene)
		return
	add_scene(client_scene)
	
	Global.gui = get_child(0)
	print(Global.gui)

func add_scene(scene: PackedScene): # Добавление сцены в дерево
	if scene == null:  # Проверка на наличие сцены
		Global.save_and_exit()
		return
	add_child(scene.instance())
