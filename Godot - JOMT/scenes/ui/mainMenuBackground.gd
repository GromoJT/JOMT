extends Node3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

func _ready() -> void:
	animation_player.play("cube_flare");
	animation_player_2.play("camera_wziu");
