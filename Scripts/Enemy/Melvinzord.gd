extends Node3D

@onready var game : Node3D = $"../"

@export var enabled : bool

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

var bonnie_left_spawn : bool = false
var chica_left_spawn : bool = false
var jumpscaring : bool = false
var waiting_to_move : bool = false

var time_left : float = 0.0
var current_countdown : float = 0.0
const MOVEMENT_INTERVAL : float = 3.97

signal jumpscare_freddy

# Called when the node enters the scene tree for the first time.
func _ready():
	if Global.Melvinzord_Sequence:
		return
	await game.ready
	$Toilet.visible = false
	$MelvinJet.visible = false
	$BattleMode.visible = true
	enabled = !(Global.current_night == 0 || Global.current_night == 1 || Global.Melvinzord_Sequence || !enabled)
	print("Melvinzord: %s" % enabled)
	
	current_pos = 0
	
	if AI_level == -1:
		rand.randomize();
		AI_level = rand.randi_range(1,2)
	
	$Timer.wait_time = MOVEMENT_INTERVAL
	$Timer.autostart = true
	$Timer.start()
	
	$JumpscareTimer.wait_time = 1.0
	$Timer.autostart = false
	print("READY")
	set_freddy_location(current_pos)
	
	if !enabled:
		AI_level = 0
	
	freddy_countdown.text = "Time Left: %.02f" % time_left

func _process(delta):
	if waiting_to_move:
		time_left -= delta
		freddy_countdown.text = "Time Left: %.02f" % time_left
	pass

func _on_timer_timeout():
	if !enabled:
		#print("FREDDY NOT ENABLED")
		return
	
	if !bonnie_left_spawn && !chica_left_spawn:
		#print("FREDDY -- SOMEONE IN SPAWN")
		return
	
	if game.watching_cam && !is_attacking:
		# print("FREDDY -- NOT ATTACKING LOCKED")
		return
	
	if watching_final_cam && is_attacking:
		# print("FREDDY -- ATTACKING LOCKED")
		return
	
	if waiting_to_move:
		print("FREDDY -- ALREADY TRYING TO MOVE")
		return
	
	rand.randomize()
	var check = rand.randi_range(1,20)
	
	if AI_level >= check:
		if is_attacking:
			attack_freddy_pattern(check)
		else:
			regular_freddy_pattern(check)
	else:
		pass
		# print("FREDDY -- %s VS %s: FAILED" % [AI_level, check])

func regular_freddy_pattern(_check : int) -> void:
	# print("FREDDY -- %s VS %s: LET'S GET MOVING" % [AI_level, check])
	# Figure out where to move to
	current_pos += 1
	
	# Start the countdown for moving
	current_countdown = calculate_countdown_duration(AI_level)
	time_left = current_countdown
	waiting_to_move = true
	await wait_to_move()
	
	print("FREDDY -- MOVE TO %s" % current_pos)
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
	#print("FREDDY -- WAITING FOR %.02fs" % current_countdown)
	await get_tree().create_timer(current_countdown).timeout
	
	if game.watching_cam:
		await $"../Player".watching_office
		print("FREDDY -- NOT WATCHING CAMS")
	
	#print("FREDDY -- READY TO MOVE!")
	waiting_to_move = false

func calculate_countdown_duration(level : int) -> float:
	return 15.0 - ((5.0/3.0) * (level - 1))

func set_freddy_location(pos : int) -> void:
	set_global_position(enemy_locations[pos].global_position)
	set_global_rotation(enemy_rotations[pos])
	
func _on_shashumga_bonnie_left_spawn():
	if bonnie_left_spawn:
		return
	bonnie_left_spawn = true
	
func _on_cabron_chica_left_spawn():
	if chica_left_spawn:
		return
	chica_left_spawn = true

func _on_player_watching_camera_num(id):
	if is_attacking:
		watching_final_cam = (id == current_pos)
	#print(watching_final_cam)

func _on_jumpscare_timer_timeout():
	if jumpscaring:
		return
	
	rand.randomize()
	var check : int = rand.randi_range(1,100)
	if check <= 25:
		print("FREDDY -- TIME TO SCARE")
		if !game.getting_scared:
			emit_signal("jumpscare_freddy")
