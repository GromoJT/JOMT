extends Control

@onready var master = "res://scenes/Levels/Master_1/Master_1.tscn"
@onready var loading_test_1 = "res://scenes/LoadingTestMaps/loading_level_test_1.tscn"
@onready var EDY_STREET = "res://scenes/Levels/EdStreet/edy_street.tscn"

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(master)
	Globals.changeLevelToVia("master")
func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_wczytaj_pressed() -> void:
	Globals.load_data(Globals.SAVE_DIR + Globals.SAVE_FILE_NAME)
	

func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file(EDY_STREET)
