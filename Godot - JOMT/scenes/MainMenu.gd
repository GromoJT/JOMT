extends Control

@onready var master = "res://scenes/Levels/Master_1.tscn"

func _on_start_pressed() -> void:
	print("KLIK")
	get_tree().change_scene_to_file(master)


func _on_exit_pressed() -> void:
	get_tree().quit()
