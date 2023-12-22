extends Node

const SAVE_DIR="user://saves/"
const SAVE_FILE_NAME = "save.json"
const SECURITY_KEY = "09SSNAE38422345SMNCAI"

var player_data = PlayerData.new()

func _ready() -> void:
	verify_save_directory(SAVE_DIR)

func verify_save_directory(path:String):
	DirAccess.make_dir_absolute(path)

func save_data(path: String,pd:PlayerData):
	var file = FileAccess.open_encrypted_with_pass(path,FileAccess.WRITE,SECURITY_KEY)
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	var data = {
		"player_data": {
			"global_position":{
				"x":pd.global_position.x,
				"y":pd.global_position.y,
				"z":pd.global_position.z
			},
			"current_location": currentScene
		}
	}
	
	var json_string = JSON.stringify(data,"\t")
	file.store_string(json_string)
	file.close()

func load_data(path:String):
	if FileAccess.file_exists(path):
		var file = FileAccess.open_encrypted_with_pass(path,FileAccess.READ,SECURITY_KEY)
		if file == null:
			print(FileAccess.get_open_error())
			return
		var content = file.get_as_text()
		file.close()
		
		var data = JSON.parse_string(content)
		if data == null:
			printerr("NIe można sparrsować %s jako json_string : (%s)" % [path,content])
			return
		
		#player_data = PlayerData.new()
		player_data.global_position = Vector3(data.player_data.global_position.x,data.player_data.global_position.y,data.player_data.global_position.z)
		currentScene = data.player_data.current_location
		loadSave()
	else:
		printerr("Nie można otwórzyć nie istniejacego pliku w %s" % [path])

const PICK_UP = preload("res://scripts/item/pick_ups/pick_up.tscn")

var levels = {
	"level_1":"res://scenes/LoadingTestMaps/loading_level_test_1.tscn",
	"level_2":"res://scenes/LoadingTestMaps/loading_level_test_2.tscn",
	"master":"res://scenes/Levels/Master_1/Master_1.tscn"
}

var currentScene: String
var enterPoint: String 

func changeLevelToVia(scene : String ,entrence : String = ""):
	enterPoint = entrence
	currentScene = scene
	print(enterPoint)
	call_deferred("loader",scene)

func loadSave():
	get_tree().change_scene_to_file(currentScene)

func loader(scene):
	get_tree().change_scene_to_file(levels[scene])

func player_send_pick_up_item_to_geometry(_slotData, _position) -> void:
	var pick_up = PICK_UP.instantiate()
	pick_up.slot_data = _slotData;
	pick_up.position = _position;
	print("OK?")
	get_tree().root.add_child(pick_up)

