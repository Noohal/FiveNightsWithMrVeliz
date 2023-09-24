extends Node3D

@onready var game : Node3D = $"../"

@export var enemy_locations : Array[Node3D]
@export var night_AI_levels : Array[int]

const MOVEMENT_INTERVAL : float = 5.0

var AI_level : int
var current_pos : int

var rand = RandomNumberGenerator.new()

signal jumpscare_chica

func _ready():
	rand.randomize()
	AI_level = night_AI_levels[game.current_night - 1]
	
	current_pos = 0
	set_global_position(enemy_locations[current_pos].global_position)

# Check Movement Opportunity
func _on_timer_timeout():
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check:
		print("Chica Moving")
	else:
		print("CHICA -- %s VS %s: STAY" % [AI_level, check])
