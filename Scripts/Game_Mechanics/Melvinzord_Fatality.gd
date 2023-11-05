extends Node3D

@onready var player : AnimationPlayer = $AnimationPlayer

func _ready():
	player.play("Deploy")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Deploy":
		player.play("Flying")
	elif anim_name == "Flying":
		player.play("Transformation")
	elif anim_name == "Transformation":
		player.play("Landing")
	elif anim_name == "Landing":
		player.play("Finisher")
	else:
		get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")
