extends Resource
class_name  ItemData

@export var naem:String = ""
@export_multiline var description:String = ""
@export var stackable: bool = false
@export var texture:AtlasTexture

func use(_target) -> void:
	pass
