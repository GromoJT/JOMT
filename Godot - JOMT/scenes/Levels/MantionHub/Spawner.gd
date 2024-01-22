extends Marker3D

@export var max_number_of_enemys:int = 100
@onready var enemies: Node3D = $".."
var cur_numb_of_enemys: int = 0

const MONSTER_1 = preload("res://scenes/mobs/monster_1.tscn")

func spawn_enemy() -> void:
	if cur_numb_of_enemys < max_number_of_enemys:
		var enmy_instance = MONSTER_1.instantiate()
		enmy_instance.player = $"../../Player"
		enmy_instance.parent_node = $".."
		enemies.add_child(enmy_instance)
		cur_numb_of_enemys = cur_numb_of_enemys+1

func _on_timer_timeout() -> void:
	pass

func decrese_number_of_enemis() -> void :
	cur_numb_of_enemys = cur_numb_of_enemys-1
