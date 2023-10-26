extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer

var can_interact = true
var on = false;

func interact():
	if can_interact:
		print("OK!")
		can_interact = false
		timer.start()
		on =!on
		if on == true:
			animation_player.play("Activate")
		if on == false:
			animation_player.play("Deactivation")


func _on_timer_timeout():
	can_interact = true
