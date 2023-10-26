extends RayCast3D

@onready var interact_ui = $InteractUI


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var coll = self.get_collider()
	if self.is_colliding():
		if coll.is_in_group("Interactable"):
			interact_ui.show()
			print("HELLO")
			if Input.is_action_just_pressed("interact"):
				coll.interact()
				
	else:
		interact_ui.hide()
		

