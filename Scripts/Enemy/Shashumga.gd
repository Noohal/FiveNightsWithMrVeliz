extends Node3D

@onready var game : Node3D = $"../"
@export var movement_points : Array[Vector3]
@export var night_AI_levels : Array[int]

var rand = RandomNumberGenerator.new()

var AI_level : int
var current_pos : int
const MOVEMENT_INTERVAL : float = 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	rand.randomize()
	AI_level = night_AI_levels[game.current_night]
	current_pos = 0
	set_global_position(movement_points[current_pos])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

# Check Movement Opportunity
func _on_timer_timeout():
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check:
		current_pos = find_new_destination(current_pos)
		set_global_position(movement_points[current_pos])
		print("%s VS %s: BONNIE MOVE TO %s" % [AI_level, check, current_pos])
		await get_tree().create_timer(4).timeout
		print("READY TO CHECK")
	else:
		print("%s VS %s: STAY BONNIE" % [AI_level, check])

# Based on current position, calculate the new position
func find_new_destination(pos : int) -> int:
	rand.randomize()
	var dest : int = 0
	match pos:
		0:
			dest = rand.randi_range(1,2)
		1:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 2
			else:
				dest = 3
		2: 
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 3
			else:
				dest = 1
		3:
			var chance = rand.randi_range(1,12)
			if chance <= 5:
				dest = 4
			elif chance <= 11:
				dest = 5
			else:
				rand.randomize()
				dest = rand.randi_range(1,2)
		4:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 5
			else:
				dest = 6
		5:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 6
			else:
				dest = 4
		6:
			dest = attack()
	return dest

func attack() -> int:
	if game.left_door_close:
		print("LEAVING")
		return 3
	print("AT DOOR")
	return 6

# Increase AI Level
func _on_clock_hour_change(hour):
	if hour == 2 || hour == 3 || hour == 4:
		AI_level += 1

