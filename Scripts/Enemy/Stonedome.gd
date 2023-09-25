extends Node3D

@onready var game : Node3D = $"../"

@export var enemy_locations : Array[Node3D]
@export var enemy_location_rotations : Array[Vector3]
@export var night_AI_levels : Array[int]

const MOVEMENT_INTERVAL : float = 5.0

var AI_level : int

# Stage 1 - Looking Away
# Stage 2 - Positioned Away
# Stage 3 - Extreme Close up on Cam
# Stage 4 - Gone from Upstairs
# Stage 5 - Downstairs and starts running
var current_stage : int

var rand = RandomNumberGenerator.new()

signal jumpscare_foxy

func _ready():
	current_stage = 1
	AI_level = night_AI_levels[game.current_night - 1]
	set_global_position(enemy_locations[0].global_position)
	set_global_rotation(enemy_location_rotations[0])

# Check Movement Opportunity
func _on_timer_timeout():
	pass # Replace with function body.
