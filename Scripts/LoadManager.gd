extends Node

signal progress_changed(progress)
signal load_complete

var load_screen_path : String = "res://Scenes/loading_screen.tscn"
var load_screen = load(load_screen_path)
var loaded_resource : PackedScene
var scene_path : String
var progress : Array = []

var use_sub_threads : bool = true

func load_scene(_scene_path : String) -> void:
	scene_path = _scene_path
	
	var new_loading_screen = load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	
	self.load_complete.connect(new_loading_screen.start_outro_animation)
	
	await Signal(new_loading_screen, "loading_screen_has_full_coverage")
	
	start_load()

func start_load() -> void:
	var state = ResourceLoader.load_threaded_request(scene_path, "", use_sub_threads)
	if state == OK:
		set_process(true)

func _process(_delta):
	var load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	match load_status:
		0, 2: #? THREAD_LOAD_INVALID_RESOURCE, THREAD_LOAD_FAILED
			set_process(false)
			return
		1: #? THREAD_LOAD_IN_PROGRESS
			return
		3: #? THREAD_LOAD_LOADED
			loaded_resource = ResourceLoader.load_threaded_get(scene_path)
			print("Load Complete")
			emit_signal("load_complete")
			get_tree().change_scene_to_packed(loaded_resource)
