extends RigidBody3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func interact() -> void:
	audio_stream_player_3d.play()
	print("MAX!")

func disable_collisions() -> void:
	collision_shape_3d.disabled = true
	mesh_instance_3d.set_layer_mask_value(1,false)
	mesh_instance_3d.set_layer_mask_value(2,true)

func enable_collisions() -> void:
	collision_shape_3d.disabled = false
	mesh_instance_3d.set_layer_mask_value(1,true)
	mesh_instance_3d.set_layer_mask_value(2,false)
