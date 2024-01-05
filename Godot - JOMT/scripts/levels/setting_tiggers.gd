extends Node3D
class_name setting_triggers
@onready var qodot_map: QodotMap = $NavigationRegion3D/QodotMap

func _ready() -> void:
	for _i in qodot_map.get_children():
		if _i.name.contains("trigger") and _i.get_class()=="Area3D":
			_i.set_collision_mask_value(5,true)
