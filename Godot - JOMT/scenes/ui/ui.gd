extends CanvasLayer
@onready var fps_meter: Label = $Control/MarginContainer/FPSMeter

const LOW_STAMINABAR_FILL = preload("res://scenes/ui/low_staminabar_fill.tres")
const NORMAL_STAMINABAR_FILL = preload("res://scenes/ui/normal_staminabar_fill.tres")
@onready var progress_bar: ProgressBar = $Control/MarginContainer/VBoxContainer/HBoxContainer/ProgressBar
var stamina : float

var staminaState: bool = true



func _ready() -> void:
	pass
	#print(get_parent().get_parent())

func _physics_process(delta: float) -> void:
	stamina = Globals.stamina
	progress_bar.value = lerp(progress_bar.value,stamina, 25 * delta)
	
	var fps = Engine.get_frames_per_second()
	fps_meter.text = "FPS: "+str(fps)
	
	if progress_bar.value < progress_bar.max_value * 0.20:
		if staminaState != false:
			staminaState = false
			change_stamina_bar_color()
	else:
		if staminaState != true:
			staminaState = true
			change_stamina_bar_color()

func change_stamina_bar_color() -> void:
	if !staminaState:
		progress_bar.add_theme_stylebox_override("fill",LOW_STAMINABAR_FILL)
	else:
		progress_bar.add_theme_stylebox_override("fill",NORMAL_STAMINABAR_FILL)
