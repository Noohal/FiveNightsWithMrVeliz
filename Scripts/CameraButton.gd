extends Area2D

enum CamerasEnum {BLANK, CAM1, CAM2, CAM3, CAM4, CAM5, CAM6, CAM7, CAM8, CAM9, CAM10, CAM11, CAM12 }
@export var camera_id : CamerasEnum

@onready var player : Node3D = $"../../../../../"

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			print("Selecting Camera %s" % camera_id)
			player.set_camera(camera_id)
