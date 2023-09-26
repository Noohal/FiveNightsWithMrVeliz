extends Node3D

@onready var game : Node3D = $"../"

@export var enemy_locations : Array[Node3D]
@export var enemy_location_rotations : Array[Vector3]
@export var night_AI_levels : Array[int]

const MOVEMENT_INTERVAL : float = 5.0

var AI_level : int
var watching_cam_6 : bool

# Stage 0 - Looking Away [O]
# Stage 1 - Positioned Away [O]
# Stage 2 - Extreme Close up on Cam [O]
# Stage 3 - Gone from Upstairs [X]
# Stage 4 - Downstairs and starts running [X]
var current_stage : int

var rand = RandomNumberGenerator.new()

signal jumpscare_foxy

func _ready():
	watching_cam_6 = false
	current_stage = 0
	AI_level = night_AI_levels[game.current_night - 1]
	set_global_position(enemy_locations[0].global_position)
	set_global_rotation(enemy_location_rotations[0])


# Check Movement Opportunity
func _on_timer_timeout():
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check && current_stage != 3:
		current_stage += 1
		print("FOXY -- ADVANCING TO STAGE %s" % current_stage)
		if !watching_cam_6:
			set_global_position(enemy_locations[current_stage].global_position)
			set_global_rotation(enemy_location_rotations[current_stage])


func _on_player_watching_camera_num(id):
	if id != 6 || current_stage != 3:
		return
	$AnimationPlayer.play("stage_4_running")
	await get_tree().create_timer(2.5).timeout
	if game.left_door_close == false:
		print("FOXY -- SUCCESS")
		await get_tree().create_timer(1).timeout
		get_tree().quit()
	else:
		print("FOXY -- FAIL")
		current_stage = 1
		set_global_position(enemy_locations[current_stage].global_position)
		set_global_rotation(enemy_location_rotations[current_stage])
