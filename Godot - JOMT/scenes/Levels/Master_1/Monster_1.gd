extends CharacterBody3D

var speed = 3 + randf_range(0.6,2.2)
var accel = 10 + randf_range(0.6,2.2)

var hp = 3

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@export var player: CharacterBody3D 
@export var parent_node : Node3D 

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	
	if player.is_on_floor():
		navigation_agent_3d.target_position = player.global_position

	direction = navigation_agent_3d.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed,accel*delta)

	move_and_slide()

func hit() -> void:
	hp = hp - 1
	if hp <= 0:
		queue_free()

