extends RigidBody3D
class_name Holdable

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	set_collision_layer_value(1,false);
	set_collision_layer_value(3,true);
	add_to_group("holdable")

func disable_collisions() -> void:
	collision_shape_3d.disabled = true
	mesh_instance_3d.set_scale(Vector3(0.5,0.5,0.5))
	collision_shape_3d.set_scale(Vector3(0.5,0.5,0.5))
	mesh_instance_3d.set_layer_mask_value(1,false)
	mesh_instance_3d.set_layer_mask_value(2,true)

func enable_collisions() -> void:
	collision_shape_3d.disabled = false
	mesh_instance_3d.set_scale(Vector3(1,1,1))
	collision_shape_3d.set_scale(Vector3(1,1,1))
	mesh_instance_3d.set_layer_mask_value(1,true)
	mesh_instance_3d.set_layer_mask_value(2,false)
