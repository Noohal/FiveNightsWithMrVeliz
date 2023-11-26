extends Node3D

@export var noise : NoiseTexture2D

@onready var UI : Control = $UI
@onready var player = $Player
@onready var night_label = $UI/Clock/MarginContainer/VBoxContainer2/NightLabel
@onready var player_camera_bar : TextureRect = $"Player/PlayerHUD/MarginContainer/VBoxContainer/TextureRect"
@onready var left_eye : ORMMaterial3D = $"Melvinzord/BattleMode/body/head/eyeball".get_surface_override_material(0)

enum CamerasEnum {
	TOGGLE = 0, CAM1 = 1, CAM2 = 2, 
	CAM3 = 3, CAM4 = 4, CAM5 = 5, 
	CAM6 = 6, CAM7 = 7, CAM8 = 8, 
	CAM9 = 9, CAM10 = 10, CAM11 = 11, 
	CAM12 = 12 }

enum EnemyEnum {
	NONE, FREDDY, BONNIE, CHICA, FOXY, GOLDEN
}

var rand = RandomNumberGenerator.new()
var elapsed_time : float = 0.0
var accumulated_time : float = 0.0

var left_door_close : bool = false
var right_door_close : bool = false
var watching_cam : bool = false

var current_night : int

var current_scaring_enemy : EnemyEnum = EnemyEnum.NONE
var getting_scared : bool = false
var begin_power_loss_jumpscare : bool = false

var freddy_playing_music : bool = false
var freddy_can_attack : bool = false

signal getting_killed
signal current_enemy_ready_to_scare(enemy : EnemyEnum)

func _ready():
	current_night = Global.current_night
	night_label.text = "Night " + str(current_night+1)
	current_scaring_enemy = EnemyEnum.NONE

func _process(delta):
	if !begin_power_loss_jumpscare:
		return
	
	elapsed_time += delta
	accumulated_time += delta
	
	# Check if enough time has passed for Freddy to appear
	#   If Freddy appears, do these things
	#     1. Play animation to turn on eyeballs
	#     2. Blinking eyes
	#     3. Play music
	#     4. Play for 10 seconds minimum
	
	if not freddy_playing_music && not freddy_can_attack:
		freddy_playing_music = freddy_appear()
	
	if freddy_playing_music && not freddy_can_attack:
		var time = rand.randf_range(0.2, 0.6)
		await get_tree().create_timer(time).timeout
		var sampled_noise : float = 10.0 * abs(noise.noise.get_noise_1d(accumulated_time))
		left_eye.emission_energy_multiplier = sampled_noise
		freddy_can_attack = freddy_disappear()
	
	# Check if enough time has passed for Freddy to disappear.
	#   If Freddy disappears:
	#     1. Wait random interval
	#     2. Turn off HUD
	#     3. Play Jumpscare
	
func freddy_appear() -> bool:
	if accumulated_time >= 20.0:
		play_freddy_music()
		print("%.02f Start singing" % accumulated_time)
		accumulated_time = 0.0
		return true
	
	if elapsed_time >= 5.0:
		rand.randomize()
		if rand.randi_range(1, 5) <= 2:
			play_freddy_music()
			print("Elapsed Time: %.02f, Accumulated Time: %.02f, Start singing" % [elapsed_time, accumulated_time])
			elapsed_time = 0.0
			accumulated_time = 0.0
			return true
	
	return false

func freddy_disappear() -> bool:
	if accumulated_time >= 20.0:
		print("%.02f Start scaring" % accumulated_time)
		accumulated_time = 0.0
		initiate_power_loss_jumpscare()
		return true
	
	if elapsed_time >= 5.0 and accumulated_time >= 10.0:
		rand.randomize()
		var check = rand.randi_range(1,5)
		print("%d%% chance" % [check * 20])
		if check <= 2:
			print("%d%%: Elapsed Time: %.02f, Accumulated Time: %.02f, Start scaring" % [check * 20, elapsed_time, accumulated_time])
			elapsed_time = 0.0
			accumulated_time = 0.0
			initiate_power_loss_jumpscare()
			return true
		elapsed_time = 0.0
	return false

func play_freddy_music() -> void:
	$Melvinzord.set_freddy_location(7)
	$"Melvinzord/BattleMode/body/head/eyeball".visible = true
	$"Melvinzord/BattleMode/body/head/eyeball2".visible = true
	$HarHarHarHar.play()

func initiate_power_loss_jumpscare() -> void:
	$HarHarHarHar.stop()
	$Melvinzord.set_freddy_location(6)
	Global.Melvinzord_Sequence = true
	get_tree().change_scene_to_file("res://Scenes/Enemy/melvinzord_fatality.tscn")
	await get_tree().create_timer(randf_range(5.0, 15.0)).timeout
	turn_off_hud()
	#$"Map/Scareroom/ScareCam".make_current()
	#$"Melvinzord/AnimationPlayer".play("fatality")
	#$"Jumpscare1".play()

func turn_off_hud():
	UI.visible = false
	player_camera_bar.visible = false
	$Player/PlayerHUD.visible = false
	emit_signal("getting_killed")

func game_over():
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_file("res://Scenes/GameOver.tscn")

func try_to_jumpscare() -> bool:
	print("GLOBAL -- TRYING TO SCARE")
	await player.watching_camera
	print("GLOBAL -- READY TO SCARE")
	return true

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
		$"Jumpscare1".play()
	else:
		$"Melvinzord/AnimationPlayer".play("fatality")
		$"Jumpscare1".play()
	game_over()

func _on_shashumga_jumpscare_bonnie():
	print(current_scaring_enemy)
	if current_scaring_enemy != EnemyEnum.NONE:
		return
	
	current_scaring_enemy = EnemyEnum.BONNIE
	getting_scared = await try_to_jumpscare()
	
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Shashumga/jumpscare".play("bonnie_boo")
	$"Jumpscare1".play()
	game_over()

func _on_cabron_jumpscare_chica():
	# The first enemy that is ready to jumpscare gets priority.
	print(current_scaring_enemy)
	if current_scaring_enemy != EnemyEnum.NONE:
		return
	
	current_scaring_enemy = EnemyEnum.CHICA
	getting_scared = await try_to_jumpscare()
	
	await get_tree().create_timer(5).timeout
	$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Cabron/AnimationPlayer2".play("chica_scare")
	$"Jumpscare1".play()
	game_over()

func _on_stonedome_jumpscare_foxy():
	getting_scared = true
	
	#$"Map/Scareroom/ScareCam".make_current()
	turn_off_hud()
	$"Stonedome/AnimationPlayer".play("attacking_player")
	$"Jumpscare1".play()
	game_over()
	
func _on_player_camera_state_change(watching):
	watching_cam = watching

func _on_power_power_loss():
	$Melvinzord.enabled = true
	
	getting_scared = true
	begin_power_loss_jumpscare = true
	
	$"Shashumga".enabled = false
	$"Stonedome".enabled = false
	$"Cabron".enabled = false
	
	var dim_value = 0.03
	$"Office/Room Light Left".set_param(Light3D.PARAM_ENERGY, dim_value)
	$"Office/Room Light Middle".set_param(Light3D.PARAM_ENERGY, dim_value)
	$"Office/Room Light Right".set_param(Light3D.PARAM_ENERGY, dim_value)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fatality":
		game_over()

func _on_player_watching_office():
	watching_cam = false

func _on_player_watching_camera():
	watching_cam = true
