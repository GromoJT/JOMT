extends Node3D

@onready var hinge: Marker3D = $Hinge
@onready var true_door: StaticBody3D = $Hinge/trueDoor
@onready var handle: Marker3D = $Hinge/trueDoor/Handle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

enum DOOR_STATE { CLOSE, OPEN_NORMAL, OPEN_BACK}

@export var cur_state : DOOR_STATE 
@export var right_door : bool = true
@export var two_way : bool = false;
@export var starts_open: bool = false;

func _physics_process(_delta: float) -> void:
	pass


func Interact(_handel : Area3D)->void:
	if animation_player.is_playing() : return
	animation_player_2.play("door_handle_use")
	if cur_state == DOOR_STATE.CLOSE:
		if !two_way:
			if right_door:
				animation_player.play("door_open_from_front")
				cur_state = DOOR_STATE.OPEN_NORMAL
			else:
				animation_player.play("door_open_from_back")
				cur_state = DOOR_STATE.OPEN_BACK
		else:
			if _handel.name == "Handle_Front":
				animation_player.play("door_open_from_front")
				cur_state = DOOR_STATE.OPEN_NORMAL
			else:
				animation_player.play("door_open_from_back")
				cur_state = DOOR_STATE.OPEN_BACK
	elif cur_state == DOOR_STATE.OPEN_NORMAL:
		animation_player.play("door_close_from_front")
		cur_state = DOOR_STATE.CLOSE
	else:
		animation_player.play("door_close_from_back")
		cur_state = DOOR_STATE.CLOSE
