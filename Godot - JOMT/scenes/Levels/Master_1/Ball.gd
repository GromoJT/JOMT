extends Holdable

@export var last_pos : Vector3 = Vector3.ZERO
@export var gp : Vector3
@export var gr : Vector3
func _ready() -> void:
	super()

func _physics_process(_delta: float) -> void:
	var new_pos = self.global_position
	#print(((new_pos - last_pos)/delta).length())
	last_pos = new_pos
	gp = global_position
	gr = global_rotation
