extends Node

func save_data():
	print("save data")

func save_and_exit():
	save_data()
	get_tree().quit()
	
