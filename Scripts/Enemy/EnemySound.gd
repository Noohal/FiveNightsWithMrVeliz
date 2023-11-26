extends Node

@onready var light_punch_1 = $LightPunch1
@onready var light_punch_2 = $LightPunch2
@onready var heavy_punch_1 = $HeavyPunch1
@onready var footsteps_1 = $Footsteps1

# Called when the node enters the scene tree for the first time.
func _ready():
	heavy_punch_1.volume_db = -10.0

func play_walking_down_stairs() -> void:
	pass

func play_light_door_punch(id : int) -> void:
	if id == 1:
		pass
	else:
		pass

func play_heavy_door_punch() -> void:
	heavy_punch_1.play()

func play_leaving_door() -> void:
	pass
