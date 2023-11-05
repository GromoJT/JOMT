extends Node3D

signal send_pick_up_item_down_to_geometry(slotData:SlotData, position:Vector3)

func _on_player_send_pick_up_item_to_geometry(slotData, position) -> void:
	send_pick_up_item_down_to_geometry.emit(slotData, position)
