extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("Hour_Change")
	await get_tree().create_timer(1.0).timeout

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Hour_Change":
		Global.current_night += 1
		Global.max_night = Global.current_night
		Global.save_data(Global.SAVE_DIR + Global.SAVE_FILE_NAME)
		get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
