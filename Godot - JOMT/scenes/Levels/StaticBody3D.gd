extends StaticBody3D

func _ready() -> void:
	pass

func interact():
	print("OK!")
	
func talk():
	DialogueManager.show_example_dialogue_balloon(load("res://dialogs/main.dialogue"))
	

func test():
	print("GOD!")
