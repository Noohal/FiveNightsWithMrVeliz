extends Control

func _on_ready():
	get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND

func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	Global.current_night = 0

func _on_quit_pressed():
	get_tree().quit()
