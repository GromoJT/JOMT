extends Node3D

const SPEED = 750.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var ray_cast_3d: RayCast3D = $RayCast3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D



func _process(delta: float) -> void:
	position += transform.basis * Vector3(0,0,-SPEED) * delta

	if ray_cast_3d.is_colliding():
		print(ray_cast_3d.get_collider())
		print("bum!")
		mesh_instance_3d.visible = false
		gpu_particles_3d.emitting = true
		await get_tree().create_timer(0.001).timeout
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
