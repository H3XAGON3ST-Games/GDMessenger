extends Control

onready var console := $console

func _ready():
	write_text("Server has been started")
	write_text("Server startup process")
	OS.window_borderless = false

func write_text(text):
	console.text = text + '\n' +  console.text
