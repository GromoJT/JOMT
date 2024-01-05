extends CanvasLayer
@onready var animation_player: AnimationPlayer = $Background/AnimationPlayer
@onready var label: Label = $Menu/MarginContainer/HBoxContainer/Label

#var peer = ENetMultiplayerPeer.new()
#@export var player_sceen : PackedScene

func _ready() -> void:
	label.text = "JOMT v"+str(Globals.game_version)
	animation_player.play("kamera_lata")




