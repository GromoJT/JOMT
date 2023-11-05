extends ColorRect
@onready var color_rect: ColorRect = $"."
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton
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
	
