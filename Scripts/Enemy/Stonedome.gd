extends Node3D

@onready var game : Node3D = $"../"
#@onready var enemy_sound = $EnemySound

@export var enabled : bool
@export var duration_label : Label
@export var lock_status : Label
@export var enemy_locations : Array[Node3D]
@export var enemy_location_rotations : Array[Vector3]
@export var night_AI_levels : Array[int]

var time_left : float = 0.0
var lock_duration : float = 0.0
const MOVEMENT_INTERVAL : float = 5.01

"""
Stage 0 - Looking Away [O]
Stage 1 - Positioned Away [O]
Stage 2 - Extreme Close up on Cam [O]
Stage 3 - Gone from Upstairs [X]
Stage 4 - Downstairs and starts running [X]
"""
var current_stage : int = 0
var AI_level : int = 1
var attack_attempts : int = 0

var watching_cameras : bool = false
var attempting_lock : bool = false
var is_locked : bool = false

const FIRST_NIGHT_GRACE_PERIOD_TIMER : float = 160.0
const LATER_NIGHT_GRACE_PERIOD_TIMER : float = 30.0

var rand = RandomNumberGenerator.new()

signal jumpscare_foxy
signal drain_power(amount : float)

"""
Every time Foxy rolls for his movement check, he will see if the player 
is watching the cameras.
--> If the player is not watching the cameras, he proceeds with the movement check.

--> If the player IS watching the cameras, Foxy automatically fails 
--> every movement check while the camera is ON. Once the player exits the camera,
--> Foxy becomes LOCKED

------> While LOCKED, Foxy will automatically fail every movement check for a
------> random duration.
"""

"""
If the player is watching the cameras, begin to lock Foxy.
	If he is already locked, don't lock him.
	Once the player is no longer watching the cameras, lock him.
"""
"""
Locking Foxy:
	Generate a random lock duration.
	Set locked variable to true
	Set attempting lock variable to false
	Create a timer with the lock duration.
	Once the timer is done, unlock Foxy
"""
"""
Movement Checks:
	If Foxy is locked or he is starting to get locked, fail
	If Foxy is NOT locked at all:
		Roll movement checks
"""
func _ready():
	await game.ready
	if !enabled:
		return
	
	if Global.current_night < 1:
		enabled = false
		$EnableTimer.wait_time = FIRST_NIGHT_GRACE_PERIOD_TIMER
	else:
		enabled = false
		var grace_period = LATER_NIGHT_GRACE_PERIOD_TIMER - 10.0 * (Global.current_night - 1)
		if grace_period <= 0.0:
			grace_period = 1.0
		$EnableTimer.wait_time = grace_period
	
	print("Stonedome: Grace Period %f, %s" % [$EnableTimer.wait_time, enabled])
	$EnableTimer.start()
	
	lock_status.text = "FOXY: Unlocked"
	
	current_stage = 0
	AI_level = night_AI_levels[game.current_night]
	set_foxy_position(0)

func _process(delta):
	if !enabled:
		return
	
	if is_locked:
		duration_label.text = "Time left: %.01f" % time_left
		time_left -= delta
	else:
		time_left = 0.0
		duration_label.text = "Time left: %.01f" % time_left
	
	if watching_cameras:
		if attempting_lock:
			pass
		else:
			attempting_lock = true
			lock_status.text = "FOXY: Attempting lock"
	else:
		if is_locked:
			attempting_lock = false
		elif attempting_lock && current_stage < 3:
			lock_foxy()

func reset_foxy() -> void:
	current_stage = 0
	set_foxy_position(current_stage)

func set_foxy_position(stage : int) -> void:
	set_global_position(enemy_locations[stage].global_position)
	set_global_rotation(enemy_location_rotations[stage])

func attack():
	# Foxy is already downstairs, so start playing the animation
	$AnimationPlayer.play("stage_4_running")
	await get_tree().create_timer(2.5).timeout
	
	# Once the animation is done, check if the left door is open.
	if game.left_door_close == false:
		print("FOXY -- wompwomp")
		lock_status.text = "FOXY: has killed you"
		initiate_jumpscare()
	else:
		lock_status.text = "FOXY: left door closed"
		blocked()
		reset_foxy()

func blocked():
	emit_signal("drain_power", (attack_attempts * 5.0) + 1.0)
	attack_attempts += 1
	#enemy_sound.play_heavy_door_punch()
	
func lock_foxy() -> void:
	if !enabled:
		return
	
	# Generate a random lock duration.
	rand.randomize()
	lock_duration = rand.randf_range(3.0, 16.0)
	time_left = lock_duration
	print("FOXY -- LOCKED FOR %.01f" % time_left)
	
	# Set attempting lock variable to false
	# Set locked variable to true
	attempting_lock = false
	lock_status.text = "Foxy: Locked"
	is_locked = true
	
	# Create a timer with the lock duration.
	await get_tree().create_timer(lock_duration).timeout
	
	# Once the timer is done, unlock Foxy
	is_locked = false
	lock_status.text = "FOXY: Unlocked"
	print("FOXY -- UNLOCKED")

func initiate_jumpscare():
	# Send him to in front of the left door
	current_stage = 4
	set_foxy_position(current_stage)
	if !game.getting_scared:
		emit_signal("jumpscare_foxy")

# Check Movement Opportunity
func _on_timer_timeout():
	if !enabled:
		return
	
	if current_stage == 3:
		#print("FOXY -- DOWNSTAIRS WAITING TO ATTACK")
		return
	
	if attempting_lock || is_locked:
		#print("FOXY -- AUTOFAIL")
		return
	
	rand.randomize()
	var check = randi_range(1,20)
	if AI_level >= check:
		# Successful Movement Check
		current_stage += 1
		if watching_cameras == false:
			set_foxy_position(current_stage)
		print("FOXY -- SUCCESS %s" % current_stage)
	else:
		#print("FOXY -- %s VS %s: STAY" % [AI_level, check])
		pass

func _on_player_watching_camera_num(id):
	if !enabled:
		return
	watching_cameras = (id != 0)
	var res = "true" if watching_cameras else "false"
	print("WATCHING CAMS -- %s" % res)
	# Check if Foxy is currently downstairs.
	if current_stage == 3:
		# Check if Player is watching Cam 5
		if id == 6:
			attack()

func _on_clock_hour_change(hour):
	if (hour == 3 || hour == 4) && enabled:
		AI_level += 1

func _on_enable_timer_timeout():
	if Global.current_night > 0:
		enabled = true
		$EnableTimer.stop()
		print("Stonedome: Grace Period Over, %s" % enabled)
