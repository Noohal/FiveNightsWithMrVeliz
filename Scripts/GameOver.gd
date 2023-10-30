extends Control

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
	Global.save_data(Global.SAVE_DIR + Global.SAVE_FILE_NAME)
