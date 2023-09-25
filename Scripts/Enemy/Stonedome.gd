extends Node3D

@onready var game : Node3D = $"../"

@export var enemy_locations : Array[Node3D]
@export var night_AI_levels : Array[int]

const MOVEMENT_INTERVAL : float = 5.0

var AI_level : int
var current_stage : int

var rand = RandomNumberGenerator.new()

signal jumpscare_foxy

func _ready():
	current_stage = 1
	AI_level = night_AI_levels[game.current_night - 1]
	
	pass
