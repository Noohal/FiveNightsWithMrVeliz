extends Node3D

@onready var game : Node3D = $"../"

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

var attempting_lock : bool = false
var is_locked : bool = false
var watching_cam_6 : bool = false

const FIRST_NIGHT_GRACE_PERIOD_TIMER : float = 160.0
const LATER_NIGHT_GRACE_PERIOD_TIMER : float = 30.0

var rand = RandomNumberGenerator.new()

signal jumpscare_foxy
signal drain_power(amount : float)

func _ready():
	await game.ready
	if !enabled:
		return
	
	if Global.current_night <= 1:
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
	
	watching_cam_6 = false
	current_stage = 0
	AI_level = night_AI_levels[game.current_night]
	set_foxy_position(0)

func _process(delta):
	if !enabled:
		return
	
	if !is_locked:
		time_left = -55.5
		# lock_status.text = "Foxy: unlocked"
	else:
		time_left -= delta
		duration_label.text = "Time left: %.02f" % time_left
		lock_status.text = "Foxy: LOCKED"
	
	if game.watching_cam && current_stage != 3:
		#print("FOXY -- LOCKING")
		attempting_lock = true

# Check Movement Opportunity
func _on_timer_timeout():
	if !enabled:
		return
		
	if is_locked || attempting_lock:
		print("FOXY -- AUTOFAIL")
		return

	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check && current_stage != 3:
		current_stage += 1
		print("FOXY -- ADVANCING TO STAGE %s" % current_stage)
		if !watching_cam_6:
			set_foxy_position(current_stage)
	else:
		#print("FOXY -- %s VS %s" % [AI_level, check])
		pass

func _on_player_watching_camera_num(id):
	if id != 6 || current_stage != 3 || !enabled:
		return
	
	print("FOXY -- RUNNING")
	$AnimationPlayer.play("stage_4_running")
	await get_tree().create_timer(3).timeout
	
	if game.left_door_close == false:
		print("FOXY -- SUCCESS")
		initiate_jumpscare()
	else:
		# print("FOXY -- FAIL")
		foxy_attack()
		reset_foxy()

func reset_foxy() -> void:
	current_stage = 1
	set_foxy_position(current_stage)
	
func initiate_jumpscare():
	# Send him to in front of the left door
	current_stage = 4
	set_foxy_position(current_stage)
	if !game.getting_scared:
		emit_signal("jumpscare_foxy")

func foxy_attack():
	emit_signal("drain_power", (attack_attempts * 5.0) + 1.0)
	attack_attempts += 1

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
func lock_foxy() -> void:
	if !enabled:
		return
	
	attempting_lock = false
	rand.randomize()
	lock_duration = rand.randf_range(3.0, 16.0)
	time_left = lock_duration
	
	is_locked = true
	print("FOXY -- LOCKED FOR %s" % lock_duration)
	
	await get_tree().create_timer(lock_duration).timeout
	is_locked = false

func set_foxy_position(stage : int) -> void:
	set_global_position(enemy_locations[stage].global_position)
	set_global_rotation(enemy_location_rotations[stage])

func _on_player_camera_state_change(watching):
	if !enabled:
		return
	if attempting_lock && !watching && current_stage != 3:
		lock_foxy()

func _on_clock_hour_change(hour):
	if (hour == 3 || hour == 4) && enabled:
		AI_level += 1

func _on_enable_timer_timeout():
	if Global.current_night > 0:
		enabled = true
		$EnableTimer.stop()
		print("Stonedome: Grace Period Over, %s" % enabled)
