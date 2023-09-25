extends Node3D

var left_door_close : bool = false
var right_door_close : bool = false

var current_night : int = 1

func _on_left_door_left_door_change(active):
	left_door_close = active

func _on_right_door_right_door_change(active):
	right_door_close = active

func _on_shashumga_jumpscare_bonnie():
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	$"Shashumga/jumpscare".play("bonnie_boo")
	$"Shashumga/scare sfx".play()
	await get_tree().create_timer(2).timeout
	get_tree().quit()

func _on_cabron_jumpscare_chica():
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	$"Cabron/AnimationPlayer".play("chica_boo")
	await get_tree().create_timer(2).timeout
	get_tree().quit()
