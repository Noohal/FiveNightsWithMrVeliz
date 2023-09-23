extends Node3D

var left_door_close : bool = false
var right_door_close : bool = false

var current_night : int = 6

func _on_left_door_left_door_change(active):
	left_door_close = active


func _on_right_door_right_door_change(active):
	right_door_close = active


func _on_shashumga_jumpscare_bonnie():
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	$"Shashumga/jumpscare".play("bonnie_boo")
	$"Shashumga/scare sfx".play()
	await get_tree().create_timer(3).timeout
	get_tree().quit()
