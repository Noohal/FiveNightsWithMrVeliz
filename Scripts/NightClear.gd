extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1.0).timeout
	$AnimationPlayer.play("Hour_Change")
	await get_tree().create_timer(1.0).timeout

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Hour_Change":
		Global.current_night += 1
		if Global.current_night == 6:
			get_tree().change_scene_to_file("res://Scenes/Menu.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/Game.tscn")
