extends CanvasLayer
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer

func _ready() -> void:
	animation_player.play("kamera_lata")
