extends Holdable

@export var holding_scale : float = 0.5
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func disable_collisions() -> void:
	collision_shape_3d.disabled = true
	mesh_instance_3d.set_scale(Vector3(holding_scale,holding_scale,holding_scale))
	collision_shape_3d.set_scale(Vector3(holding_scale,holding_scale,holding_scale))
	mesh_instance_3d.set_layer_mask_value(1,false)
	mesh_instance_3d.set_layer_mask_value(2,true)

func enable_collisions() -> void:
	collision_shape_3d.disabled = false
	mesh_instance_3d.set_scale(Vector3(holding_scale,holding_scale,holding_scale))
	collision_shape_3d.set_scale(Vector3(holding_scale,holding_scale,holding_scale))
	mesh_instance_3d.set_layer_mask_value(1,true)
	mesh_instance_3d.set_layer_mask_value(2,false)

func activate_melody() -> void:
	audio_stream_player_3d.play()

func stop_melody() -> void:
	audio_stream_player_3d.stop()
