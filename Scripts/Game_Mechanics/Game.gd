extends Node3D

@export var noise : NoiseTexture2D

@onready var UI : Control = $UI
@onready var NightLabel : Label = $UI/Clock/MarginContainer/NightLabel
@onready var player_camera_bar : ColorRect = $"Player/PlayerHUD/MarginContainer/VBoxContainer/ColorRect"
@onready var left_eye : ORMMaterial3D = $"Melvinzord/BattleMode/body/head/eyeball".get_surface_override_material(0)

var rand = RandomNumberGenerator.new()
var elapsed_time : float = 0.0
var accumulated_time : float = 0.0

var freddy_playing_music_box : bool = false
var eyes_on : bool = false

var left_door_close : bool = false
var right_door_close : bool = false
var watching_cam : bool = false

var current_night : int

var getting_scared : bool = false
var freddy_can_attack : bool = false
var power_loss_jumpscare : bool = false

signal getting_killed

func _ready():
	
	current_night = Global.current_night
	NightLabel.text = "Night " + str(current_night+1)

func _process(delta):
	if !power_loss_jumpscare:
		return
	elapsed_time += delta
	accumulated_time += delta
	
	if freddy_playing_music_box:
		rand.randomize()
		var time = rand.randf_range(0.2, 0.6)
		await get_tree().create_timer(time).timeout
		var sampled_noise : float = 10.0 * abs(noise.noise.get_noise_1d(accumulated_time))
		left_eye.emission_energy_multiplier = sampled_noise
		
	if accumulated_time >= 20.0:
		if freddy_playing_music_box:
			await get_tree().create_timer(1.2).timeout
			freddy_power_jumpscare()
		else:
			turn_on_the_music()
		elapsed_time = 0.0
	elif elapsed_time >= 5.0:
		if !freddy_playing_music_box:
			if freddy_appears():
				turn_on_the_music()
		else:
			if turn_off_music():
				freddy_power_jumpscare()
		elapsed_time = 0.0

func freddy_appears() -> bool:
	rand.randomize()
	if rand.randi_range(1,5) <= 2:
		return true
	return false

func turn_on_the_music() -> void:
	$Melvinzord.set_freddy_location(7)
	$"Melvinzord/BattleMode/body/head/eyeball".visible = true
	$"Melvinzord/BattleMode/body/head/eyeball2".visible = true
	$HarHarHarHar.play()
	freddy_playing_music_box = true
	accumulated_time = 0.0

func turn_off_music() -> bool:
	rand.randomize()
	if rand.randi_range(1,5) <= 2:
		return true
	return false

func freddy_power_jumpscare() -> void:
	power_loss_jumpscare = false
	$HarHarHarHar.stop()
	eyes_on = true
	#$Melvinzord.set_freddy_location(6)
	Global.Melvinzord_Sequence = true
	get_tree().change_scene_to_file("res://Scenes/Enemy/melvinzord_fatality.tscn")
	await get_tree().create_timer(randf_range(3.0, 5.0)).timeout
	#turn_off_hud()
	#$"Map/Scareroom/ScareCam".make_current()
	#$"Melvinzord/AnimationPlayer".play("fatality")
	#game_over()
	
func turn_off_hud():
	UI.visible = false
	player_camera_bar.visible = false
	emit_signal("getting_killed")

func game_over():
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

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
		#$"Jumpscare1".play()
	else:
		$"Melvinzord/AnimationPlayer".play("fatality")
		#$"Jumpscare1".play()
	game_over()

func _on_shashumga_jumpscare_bonnie():
	getting_scared = true
	
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Shashumga/jumpscare".play("bonnie_boo")
	#$"Jumpscare1".play()
	game_over()

func _on_cabron_jumpscare_chica():
	getting_scared = true
	
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Cabron/AnimationPlayer".play("chica_scare")
	#$"Jumpscare1".play()
	game_over()

func _on_stonedome_jumpscare_foxy():
	getting_scared = true
	
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Stonedome/AnimationPlayer".play("stage_5_running")
	#$"Jumpscare1".play()
	game_over()
	
func _on_player_camera_state_change(watching):
	watching_cam = watching

func _on_power_power_loss():
	$Melvinzord.enabled = true
	
	getting_scared = true
	power_loss_jumpscare = true
	
	$"Shashumga".enabled = false
	$"Stonedome".enabled = false
	$"Cabron".enabled = false
	
	var dim_value = 0.05
	$"Office/Room Light Left".set_param(Light3D.PARAM_ENERGY, dim_value)
	$"Office/Room Light Middle".set_param(Light3D.PARAM_ENERGY, dim_value)
	$"Office/Room Light Left2".set_param(Light3D.PARAM_ENERGY, dim_value)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fatality" && eyes_on:
		game_over()
