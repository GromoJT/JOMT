extends Node3D

@onready var animated_sprite_3d: AnimatedSprite3D = $World/AnimatedSprite3D
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var collision_shape_3d_monster: CollisionShape3D = $World/Area3DMonsterQuit/CollisionShape3DMonster
@onready var items: Node3D = $World/Items
#const PICK_UP = preload("res://scripts/item/pick_ups/pick_up.tscn")


func _ready() -> void:
	animated_sprite_3d.visible = false
	
#func _on_player_send_pick_up_item_to_geometry(_slotData, _position) -> void:
	#var pick_up = PICK_UP.instantiate()
	#pick_up.slot_data = _slotData;
	#pick_up.position = _position;
	#print("OK?")
	#get_tree().root.add_child(pick_up)


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Player"):
		strach()
		


func _on_area_3d_monster_quit_area_entered(area: Area3D) -> void:
	if area.is_in_group("Player"):
		get_tree().quit()

func strach() -> void:
	animated_sprite_3d.visible = true
	animated_sprite_3d.play("monster_show")
	audio_stream_player_3d.play()
	collision_shape_3d_monster.call_deferred("set_disabled",false)
