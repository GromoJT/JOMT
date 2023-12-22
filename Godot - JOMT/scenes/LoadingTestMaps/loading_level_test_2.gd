extends Node3D

@onready var spawn_point: Marker3D = $SpawnPoint
@onready var entrance_1: Marker3D = $Entrance_1
@onready var player: CharacterBody3D = $Player

func _ready() -> void:
	if Globals.enterPoint.is_empty() or Globals.enterPoint == "":
		player.global_position = spawn_point.global_position
		player.rotation = spawn_point.rotation
	else:
		player.global_position = get_node(Globals.enterPoint).global_position
		player.rotation = get_node(Globals.enterPoint).rotation
