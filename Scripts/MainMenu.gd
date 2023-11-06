extends Control

var screen_size
@export var continue_btn : Control

func _ready():
	if Global.max_night != 0:
		continue_btn.show()

func _on_continue_pressed():
	print("Continue to Night %d" % (Global.max_night+1))
	Global.current_night = Global.max_night
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")
	
func _on_new_game_pressed():
	print("Start a new Game")
	Global.current_night = 0
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_options_pressed():
	pass # Replace with function body.

func _on_quit_pressed():
	get_tree().quit()
