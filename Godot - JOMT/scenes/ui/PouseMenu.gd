extends ColorRect
@onready var color_rect: ColorRect = $"."
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var  MAIN_MENU = "res://scenes/main_menu.tscn"
signal unPouse

func _unhandled_input(_event: InputEvent) -> void:
	if get_tree().paused and Input.is_action_just_pressed("esc"):
		unpause()

func _ready() -> void:
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)

func unpause():
#	print("nie pauza")
	get_tree().paused = false
	
	unPouse.emit()
func pause():
#	print("pauza")
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)


func _on_button_2_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene();


func _on_save_pressed() -> void:
	var pd : PlayerData = PlayerData.new()
	print(get_parent().get_parent().get_parent().get_node("Player").get_global_position())
	pd.global_position = get_parent().get_parent().get_parent().get_node("Player").get_global_position()
	Globals.save_data(Globals.SAVE_DIR + Globals.SAVE_FILE_NAME,pd)
