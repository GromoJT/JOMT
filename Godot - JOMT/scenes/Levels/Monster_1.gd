extends CharacterBody3D

var speed = 3
var accel = 10

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var player: CharacterBody3D = $"../../../Player"

func _physics_process(delta: float) -> void:
	var direction = Vector3()
	
	navigation_agent_3d.target_position = player.global_position
	
	direction = navigation_agent_3d.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed,accel*delta)

	move_and_slide()
