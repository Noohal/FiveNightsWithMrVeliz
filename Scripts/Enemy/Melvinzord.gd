extends Node3D

@onready var game : Node3D = $"../"

@export var enemy_locations : Array[Node3D]
@export var night_AI_levels : Array[int]

var rand = RandomNumberGenerator.new()

var AI_level : int = 1
var current_pos : int = 1

const MOVEMENT_INTERVAL : float = 3.97

# Called when the node enters the scene tree for the first time.
func _ready():
	AI_level = night_AI_levels[game.current_night - 1]
	current_pos = 0
	set_freddy_location(current_pos)

func set_freddy_location(pos : int) -> void:
	set_global_position(enemy_locations[pos].global_position)
	set_global_rotation(enemy_locations[pos].global_rotation)
