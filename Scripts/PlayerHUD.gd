extends Control

@onready var player : Node3D = get_parent()
@onready var map : Node2D = $"MarginContainer/HBoxContainer/ButtonMap"

var playing_animation = false

func toggle_ui(enable : bool) -> void:
	if enable:
		map.show()
	else:
		map.hide()

func _on_color_rect_mouse_entered():
	if playing_animation == false:
		player.toggle_camera()

func _on_animation_player_animation_started(_anim_name):
	# print("STARTING " + anim_name)
	playing_animation = true

func _on_animation_player_animation_finished(_anim_name):
	# print(anim_name + " FINISHED")
	playing_animation = false
