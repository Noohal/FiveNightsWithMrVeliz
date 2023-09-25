extends Node3D

@onready var game : Node3D = $"../"

@export var enemy_locations : Array[Node3D]
@export var night_AI_levels : Array[int]

var rand = RandomNumberGenerator.new()

var AI_level : int
var current_pos : int
const MOVEMENT_INTERVAL : float = 5.0

var enabled : bool

signal jumpscare_chica

func _ready():
	enabled = false
	rand.randomize()
	#AI_level = 19
	AI_level = night_AI_levels[game.current_night - 1]
	
	current_pos = 0
	set_global_position(enemy_locations[current_pos].global_position)
	set_global_rotation(Vector3(0,deg_to_rad(0),0))

# Check Movement Opportunity
func _on_timer_timeout():
	if !enabled:
		return
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check:
		current_pos = find_new_destination(current_pos)
		set_global_position(enemy_locations[current_pos].global_position)
		print("CHICA -- %s VS %s: MOVE TO %s" % [AI_level, check, current_pos])
		await get_tree().create_timer(4).timeout
	else:
		print("CHICA -- %s VS %s: STAY" % [AI_level, check])

func find_new_destination(pos : int) -> int:
	rand.randomize()
	var dest = pos
	match pos:
		0:
			dest = 1
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
				dest = 4
		3:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 2
			else:
				dest = 4
		4:
			var chance = rand.randi_range(1,10)
			if chance <= 2:
				dest = 1
			else:
				dest = 5
		5:
			var chance = rand.randi_range(1,10)
			if chance <= 3:
				dest = 4
			else:
				dest = 6
		6:
			var chance = rand.randi_range(1,10)
			if chance <= 7:
				dest = 7
				print("AT DOOR")
			else:
				dest = 4
		7:
			dest = attack()
			if dest == 8:
				emit_signal("jumpscare_chica")
				set_global_rotation(Vector3(0,deg_to_rad(-180.0),0))
		_:
			dest = dest
	return dest

func attack() -> int:
	if game.right_door_close:
		print("LEAVING")
		return 4
	return 8

func _on_clock_hour_change(hour):
	if (hour == 3 || hour == 4) && enabled:
		AI_level += 1
