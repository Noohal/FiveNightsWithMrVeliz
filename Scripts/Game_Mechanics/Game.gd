extends Node3D

var rand = RandomNumberGenerator.new()

var left_door_close : bool = false
var right_door_close : bool = false
var watching_cam : bool = false

var current_night : int = 6

var freddy_can_attack : bool = false

func _on_left_door_left_door_change(active):
	left_door_close = active

func _on_right_door_right_door_change(active):
	right_door_close = active

func _on_melvinzord_jumpscare_freddy():
	await get_tree().create_timer(3).timeout
	$"Map/Scareroom/ScareCam".make_current()
	$"Melvinzord/AnimationPlayer".play("change_into_super_toilet")
	exit_game()

func _on_shashumga_jumpscare_bonnie():
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	$"Shashumga/jumpscare".play("bonnie_boo")
	$"Shashumga/scare sfx".play()
	exit_game()

func _on_cabron_jumpscare_chica():
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	$"Cabron/AnimationPlayer".play("chica_scare")
	exit_game()

func _on_stonedome_jumpscare_foxy():
	$"Map/Scareroom/ScareCam".make_current()
	$"Stonedome/AnimationPlayer".play("stage_5_running")
	exit_game()

func exit_game():
	await get_tree().create_timer(2).timeout
	get_tree().quit()

func _on_player_camera_state_change(watching):
	watching_cam = watching
