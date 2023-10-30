extends Control

var screen_size
@export var continue_btn : Control

func _ready():
	if Global.max_night == 0:
		print("Start a new Game")
	else:
		print("Continue to Night %d" % (Global.max_night+1))
		continue_btn.show()

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	Global.current_night = Global.max_night
	
func _on_new_game_pressed():
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	Global.current_night = 0

func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
