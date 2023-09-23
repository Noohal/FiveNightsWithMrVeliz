extends Node3D

var left_door_close : bool = false
var right_door_close : bool = false

var current_night : int = 0

func _on_left_door_left_door_change(active):
	left_door_close = active


func _on_right_door_right_door_change(active):
	right_door_close = active
