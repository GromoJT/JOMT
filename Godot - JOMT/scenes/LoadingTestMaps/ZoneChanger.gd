extends Area3D

@export var nextScene : String
@export var entrancePoint : String

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Player"):
		Globals.changeLevelToVia(nextScene,entrancePoint)
