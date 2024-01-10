extends Node3D

#@onready var animated_sprite_3d: AnimatedSprite3D = $World/AnimatedSprite3D
#@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
#@onready var collision_shape_3d_monster: CollisionShape3D = $World/Area3DMonsterQuit/CollisionShape3DMonster
@onready var items: Node3D = $World/Items
#const PICK_UP = preload("res://scripts/item/pick_ups/pick_up.tscn")
@onready var animation_player_for_objects: AnimationPlayer = $World/additional_objects/AnimationPlayer_for_objects
@onready var maxwell_pedestal_trigger: Area3D = $World/additional_triggers/Maxwell_pedestal_trigger
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $World/additional_objects/BigDingus/AudioStreamPlayer3D

var bigDingusState:bool = false

func _ready() -> void:
	animation_player_for_objects.set_movie_quit_on_finish_enabled(true)
	animation_player_for_objects.play("catScare",-1,-1,true)




func _on_maxwell_pedestal_trigger_body_entered(body: Node3D) -> void:
	if body.is_in_group("MaxWellHoldabel"):
		print("Maxwell!")
		bigDingusState = true
		animation_player_for_objects.play("catScare")
		audio_stream_player_3d.play()
	if body.is_in_group("tape"):
		body.activate_melody()

func _on_maxwell_pedestal_trigger_body_exited(_body: Node3D) -> void:
	if bigDingusState and _body.is_in_group("MaxWellHoldabel"):
		bigDingusState = false
		animation_player_for_objects.play("catScare",-1,-1,true)
		audio_stream_player_3d.stop()
	if _body.is_in_group("tape"):
		_body.stop_melody()
