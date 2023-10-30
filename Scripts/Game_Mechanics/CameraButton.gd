extends Area2D

enum CamerasEnum {TOGGLE, CAM1, CAM2, CAM3, CAM4, CAM5, CAM6, CAM7, CAM8, CAM9, CAM10, CAM11, CAM12 }
@export var camera_id : CamerasEnum

@onready var player_reg : Node3D = $"../../../../../../"
@export var player_sta : Node3D
@onready var player_hud : Control = $"../../../../"

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
		if camera_id != CamerasEnum.TOGGLE:
			if camera_id == CamerasEnum.CAM1 || camera_id == CamerasEnum.CAM2:
				print(player_sta.name)
				player_sta.set_camera(camera_id)
				#$"../../../../../../SwitchCams".play()
			else:
				player_reg.set_camera(camera_id)
				#$"../../../../../../SwitchCams".play()
		else:
			if player_hud.has_method("toggle_upstairs"):
				player_hud.toggle_upstairs()
