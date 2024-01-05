extends RigidBody3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

func interact() -> void:
	audio_stream_player_3d.play()
