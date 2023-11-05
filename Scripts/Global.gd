extends Node

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.json"
const SECURITY_KEY = "3F42T98H67"

# Night as 0 index
var current_night : int
var max_night : int

var Melvinzord_Sequence : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	verify_save_directory(SAVE_DIR)
	load_data(SAVE_DIR + SAVE_FILE_NAME)
	
func verify_save_directory(path : String):
	DirAccess.make_dir_absolute(path)

func save_data(path : String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return
	
	var data = {
		"player_data": {
			"max_night": Global.max_night
		}
	}
	
	print("SAVED MAX_NIGHT AS %s" % data.player_data.max_night)
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()

func load_data(path : String):
	if !FileAccess.file_exists(path):
		printerr("Cannot open file at %s" % path)
		return
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		print(FileAccess.get_open_error())
		return
	var content = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(content)
	if data == null:
		printerr("Cannot parse %s as a json_string: (%s)" % [path, content])
		return
	
	if data.player_data.max_night == -1:
		data.player_data.max_night = 0
	elif data.player_data.max_night > 6:
		data.player_data.max_night = 6
	else:
		pass
	
	max_night = data.player_data.max_night
	print("MAX NIGHT: %s" %  max_night)
