extends Resource
class_name  SlotData

const MAX_STACK_SIZE: int = 99

@export var item_data :ItemData
@export_range(1,MAX_STACK_SIZE) var qunatity: int = 1 : set = set_quantity

func set_quantity(value: int) -> void:
	qunatity = value
	if qunatity > 1 and not item_data.stackable:
		qunatity = 1
		push_error("% is not stacable, setting quantity to 1" % item_data.naem) 

func create_single_slot_data() -> SlotData:
	var new_slot_data = duplicate()
	new_slot_data.qunatity = 1
	qunatity -=1
	return new_slot_data

func can_merge_with(other_slot_data:SlotData)-> bool:
	return item_data == other_slot_data.item_data \
			and item_data.stackable \
			and qunatity  < MAX_STACK_SIZE

func can_fully_merge_with(other_slot_data:SlotData)-> bool:
	return item_data == other_slot_data.item_data \
			and item_data.stackable \
			and qunatity + other_slot_data.qunatity < MAX_STACK_SIZE

func fully_merge_with(other_slot_data:SlotData)-> void:
	qunatity += other_slot_data.qunatity
