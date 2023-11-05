extends RigidBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $CollisionShape3D/MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func schrink():
	mesh_instance_3d.set_scale(Vector3(0.5,0.5,0.5))

func deshrink():
	mesh_instance_3d.set_scale(Vector3(1,1,1))
func disable_collisions():
#	print("Disabled")
	collision_shape_3d.disabled = true
	mesh_instance_3d.set_layer_mask_value(1,false);
	mesh_instance_3d.set_layer_mask_value(2,true);
	schrink()
func enable_collisions():
#	print("Enabled")
	collision_shape_3d.disabled = false
	mesh_instance_3d.set_layer_mask_value(1,true);
	mesh_instance_3d.set_layer_mask_value(2,false);
	deshrink()
