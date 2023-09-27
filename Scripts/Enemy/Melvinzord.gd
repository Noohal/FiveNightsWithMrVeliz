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
var current_pos : int = 1

var bonnie_left_spawn : bool = false
var chica_left_spawn : bool = false
var waiting_to_move : bool = false

var time_left : float = 0.0
var current_countdown : float = 0.0
const MOVEMENT_INTERVAL : float = 3.97

# Called when the node enters the scene tree for the first time.
func _ready():
	current_pos = 0
	AI_level = 10
	# AI_level = night_AI_levels[game.current_night - 1]
	
	$Timer.wait_time = MOVEMENT_INTERVAL
	$Timer.autostart = true
	$Timer.start()
	set_freddy_location(current_pos)
	
	freddy_countdown.text = "Time Left: %.02f" % time_left

func _process(delta):
	if waiting_to_move:
		time_left -= delta
		freddy_countdown.text = "Time Left: %.02f" % time_left
	else:
		time_left = current_countdown
	pass

func set_freddy_location(pos : int) -> void:
	set_global_position(enemy_locations[pos].global_position)
	set_global_rotation(enemy_rotations[pos])

func _on_timer_timeout():
	if !enabled:
		return
	
	if game.watching_cam && !waiting_to_move:
		print("FREDDY -- AUTO FAIL")
		return
	
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check && !waiting_to_move: 
		current_pos += 1
		
		current_countdown = determine_countdown_duration(AI_level)
		time_left = current_countdown
		
		await get_tree().create_timer(current_countdown).timeout
		
		if !game.watching_cams:
			waiting_to_move = false
		else:
			await wait_to_move()
		
		if bonnie_left_spawn:
			print("FREDDY -- %s VS %s: MOVING TO %s" % [AI_level, check, current_pos])
			#move_freddy(current_pos)
		else:
			print("FREDDY -- %s VS %s: TRY AGAIN LATER" % [AI_level, check, current_pos])

func wait_to_move():
	print("FREDDY -- WAITING TO MOVE")
	await $"../Player".watching_office
	print("FREDDY -- GO GO GO!")
	waiting_to_move = false

func determine_countdown_duration(level : int) -> float:
	return 15.0 - ((5.0/3.0) * (level - 1))

func _on_player_camera_state_change(_watching):
	pass
	"""
	if !watching:
		waiting_to_move = false
		move_freddy(current_pos)
	"""

func _on_shashumga_bonnie_left_spawn():
	if bonnie_left_spawn:
		return
	bonnie_left_spawn = true
