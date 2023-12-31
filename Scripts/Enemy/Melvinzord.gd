extends Node3D

@onready var game : Node3D = $"../"
@onready var freddy_laugh_1 = $FreddyLaugh1
@onready var freddy_laugh_2 = $FreddyLaugh2

@export var enabled : bool

@export var freddy_giggle_label : Label
@export var freddy_status : Label
@export var freddy_countdown : Label

@export var enemy_locations : Array[Node3D]
@export var enemy_rotations : Array[Vector3]
@export var night_AI_levels : Array[int]

var rand = RandomNumberGenerator.new()

var AI_level : int = 1
var current_pos : int = 0

var is_attacking : bool = false
var watching_final_cam : bool = false
var watching_cams : bool = false

var bonnie_moving : bool = false
var chica_moving : bool = false

var jumpscaring : bool = false
var waiting_to_move : bool = false

var power_loss_jumpscare : bool = false

var time_left : float = 0.0
var current_countdown : float = 0.0
const MOVEMENT_INTERVAL : float = 3.97

signal jumpscare_freddy

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.Melvinzord_Sequence || !enabled:
		return
	await game.ready
	$Toilet.visible = false
	$MelvinJet.visible = false
	$BattleMode.visible = true
	$"BattleMode/body/head/eyeball".visible = true
	$"BattleMode/body/head/eyeball2".visible = true
	enabled = !(Global.current_night == 0 || Global.current_night == 1 || Global.Melvinzord_Sequence || !enabled)
	print("Melvinzord: %s" % enabled)
	enabled = false
	current_pos = 0
	
	if AI_level == -1:
		rand.randomize();
		AI_level = 10
		#AI_level = rand.randi_range(1,2)
	
	$Timer.wait_time = MOVEMENT_INTERVAL
	$Timer.autostart = false
	
	$JumpscareTimer.wait_time = 1.0
	set_freddy_location(current_pos)
	
	freddy_countdown.text = "Time Left: %.02f" % time_left

func _process(delta):
	if waiting_to_move:
		time_left -= delta
		freddy_countdown.text = "Time Left: %.02f" % time_left

func _on_timer_timeout():
	if !enabled || power_loss_jumpscare:
		print("NOT ENABLED")
		return
	
	if watching_cams && !is_attacking:
		#print("FREDDY -- NOT ATTACKING LOCKED")
		return
	
	if watching_final_cam && is_attacking:
		#print("FREDDY -- ATTACKING LOCKED")
		return
	
	if waiting_to_move:
		#print("FREDDY -- ALREADY TRYING TO MOVE")
		return
	
	rand.randomize()
	var check = rand.randi_range(1,20)
	
	if AI_level >= check:
		if is_attacking:
			attack_freddy_pattern(check)
		else:
			regular_freddy_pattern(check)
	else:
		#print("FREDDY -- %s VS %s: FAILED" % [AI_level, check])
		pass

func regular_freddy_pattern(_check : int) -> void:
	if power_loss_jumpscare:
		return
	#print("FREDDY -- %s VS %s: LET'S GET MOVING" % [AI_level, check])
	# Figure out where to move to
	current_pos += 1
	
	# Start the countdown for moving
	current_countdown = calculate_countdown_duration(AI_level)
	time_left = current_countdown
	waiting_to_move = true
	await wait_to_move()
	
	print("FREDDY -- MOVE TO %s" % current_pos)
	if rand.randi_range(1,2) == 1:
		freddy_laugh_1.play()
		freddy_giggle_label.text = "Sound 1"
	else:
		freddy_laugh_2.play()
		freddy_giggle_label.text = "Sound 2"
	set_freddy_location(current_pos)
	
	if current_pos == 5:
		is_attacking = true
		freddy_status.text = "FREDDY: ATTACKING"
"""
Checklist for Freddy Jumpscare
[V] Successful Movement Opportunity
[X] Freddy is at Cam 5
[X] Player looking at different camera
[X] Door is open
"""
func attack_freddy_pattern(_check : int) -> void:
	if power_loss_jumpscare:
		return
	print("FREDDY -- ATTACKING")
	# Check if we are currently at Cam 5
	if current_pos == 5:
		# If we are on Cam 5, then check if the player is looking at a different camera
		# Check if the door is open
		if !watching_final_cam && !game.right_door_close:
			current_countdown = calculate_countdown_duration(AI_level)
			time_left = current_countdown
			waiting_to_move = true
			await wait_to_move()
			
			initiate_jumpscare()
		else:
			print("FREDDY -- ATTACKING: Failed Attack Attempt, Moving Back")
			current_pos = 4
			
			current_countdown = calculate_countdown_duration(AI_level)
			time_left = current_countdown
			waiting_to_move = true
			await wait_to_move()
			
			set_freddy_location(current_pos)
		pass
	elif current_pos < 5:
		current_pos += 1
		
		current_countdown = calculate_countdown_duration(AI_level)
		time_left = current_countdown
		waiting_to_move = true
		await wait_to_move()
		
		print("FREDDY -- ATTACKING: Moving to %s" % current_pos)
		set_freddy_location(current_pos)
	else:
		pass

func initiate_jumpscare() -> void:
	if power_loss_jumpscare:
		return
	current_pos += 1
	print("INITIATE JUMPSCARE")
	set_freddy_location(current_pos)
	
	# Once Freddy is in the office, check if the player is watching the cameras.
	# If the player is watching the cameras, wait until they turn it off.
	# Otherwise, start the countdown for jumpscaring
	if game.watching_cam:
		print("FREDDY -- In Office. Waiting to turn down the camera.")
		await $"../Player".watching_office
	
	print("FREDDY -- In Office. Check for Jumpscare")
	$JumpscareTimer.autostart = true
	$JumpscareTimer.start()

func wait_to_move():
	if power_loss_jumpscare:
		return
	#print("FREDDY -- WAITING FOR %.02fs" % current_countdown)
	await get_tree().create_timer(current_countdown).timeout
	
	if watching_cams:
		await $"../Player".watching_office
		#print("FREDDY -- NOT WATCHING CAMS")
	
	#print("FREDDY -- READY TO MOVE!")
	waiting_to_move = false

func calculate_countdown_duration(level : int) -> float:
	return 15.0 - ((5.0/3.0) * (level - 1))

func set_freddy_location(pos : int) -> void:
	set_global_position(enemy_locations[pos].global_position)
	set_global_rotation(enemy_rotations[pos])
	
func _on_shashumga_bonnie_left_spawn():
	bonnie_moving = true
	if chica_moving:
		if Global.current_night <= 2 || Global.Melvinzord_Sequence:
			enabled = false
		else:
			enabled = true
			$Timer.start()
	else:
		enabled = false
	
func _on_cabron_chica_left_spawn():
	chica_moving = true
	if bonnie_moving:
		if Global.current_night <= 2 || Global.Melvinzord_Sequence:
			enabled = false
		else:
			enabled = true
			$Timer.start()
	else:
		enabled = false

func _on_player_watching_camera_num(id):
	if id == 0:
		watching_cams = false
	else:
		watching_cams = true
	
	if is_attacking:
		watching_final_cam = (id == current_pos)
	#print(watching_final_cam)

func _on_jumpscare_timer_timeout():
	if jumpscaring:
		return
	
	rand.randomize()
	var check : int = rand.randi_range(1,100)
	if check <= 25:
		#print("FREDDY -- TIME TO SCARE")
		if !game.getting_scared:
			emit_signal("jumpscare_freddy")

func _on_power_power_loss():
	power_loss_jumpscare = true
