extends Node3D

@onready var UI : Control = $UI
@onready var player_camera_bar : ColorRect = $"Player/PlayerHUD/MarginContainer/VBoxContainer/ColorRect"

var rand = RandomNumberGenerator.new()

var left_door_close : bool = false
var right_door_close : bool = false
var watching_cam : bool = false

var current_night : int = 6

var getting_scared : bool = false
var freddy_can_attack : bool = false

signal getting_killed

func _on_left_door_left_door_change(active):
	left_door_close = active

func _on_right_door_right_door_change(active):
	right_door_close = active

func _on_melvinzord_jumpscare_freddy():
	getting_scared = true
	
	await get_tree().create_timer(3).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	rand.randomize()
	var check = randi_range(1,2)
	print("FREDDY -- JUMPSCARE %s" % check)
	if check == 1:
		$"Melvinzord/AnimationPlayer".play("change_into_super_toilet")
	else:
		$"Melvinzord/AnimationPlayer".play("fatality")
	exit_game()

func _on_shashumga_jumpscare_bonnie():
	getting_scared = true
	
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Shashumga/jumpscare".play("bonnie_boo")
	$"Shashumga/scare sfx".play()
	exit_game()

func _on_cabron_jumpscare_chica():
	getting_scared = true
	
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Cabron/AnimationPlayer".play("chica_scare")
	exit_game()

func _on_stonedome_jumpscare_foxy():
	getting_scared = true
	
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Stonedome/AnimationPlayer".play("stage_5_running")
	exit_game()

func turn_off_hud():
	UI.visible = false
	player_camera_bar.visible = false
	emit_signal("getting_killed")

func exit_game():
	await get_tree().create_timer(2).timeout
	get_tree().quit()

func _on_player_camera_state_change(watching):
	watching_cam = watching
