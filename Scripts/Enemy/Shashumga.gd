extends Node3D

@onready var game : Node3D = $"../"
@onready var enemy_sound = $EnemySound

@export var enabled : bool
@export var scare_cam : Camera3D
@export var enemy_locations : Array[Node3D]
@export var enemy_rotations : Array[Vector3]
@export var night_AI_levels : Array[int]

var camera_dict = {
	9: 0,
	7: 1,
	10: 2,
	11: 3,
	1: 4,
	3: 5
}

var rand = RandomNumberGenerator.new()

var AI_level : int
var current_pos : int
var next_pos : int

var watching_current_position : bool = false

const FIRST_NIGHT_GRACE_PERIOD_TIMER : float = 160.0
const LATER_NIGHT_GRACE_PERIOD_TIMER : float = 30.0
const MOVEMENT_INTERVAL : float = 4.6

signal bonnie_left_spawn
signal bonnie_moving(old : int, new : int)
signal jumpscare_bonnie

# Called when the node enters the scene tree for the first time.
func _ready():
	await game.ready
	if !enabled:
		return
	
	if Global.current_night < 1:
		enabled = false
		$EnableTimer.wait_time = FIRST_NIGHT_GRACE_PERIOD_TIMER
	else:
		enabled = false
		var grace_period = LATER_NIGHT_GRACE_PERIOD_TIMER - 10.0 * (Global.current_night - 1)
		if grace_period <= 0.0:
			grace_period = 1.0
		$EnableTimer.wait_time = grace_period
	
	print("Guac of Mole: Grace Period %f, %s" % [$EnableTimer.wait_time, enabled])
	$EnableTimer.start()
	rand.randomize()
	AI_level = night_AI_levels[game.current_night]
	current_pos = 0
	set_bonnie_position(current_pos)

# Check Movement Opportunity
func _on_timer_timeout():
	if !enabled:
		return
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check:
		next_pos = find_new_destination(current_pos)
		if watching_current_position:
			print("BONNIE -- PLAYING STATIC")
			emit_signal("bonnie_moving", current_pos, camera_dict.find_key(next_pos) - 1)
		await get_tree().create_timer(0.25).timeout
		current_pos = next_pos
		set_bonnie_position(current_pos)
		print("BONNIE -- %s VS %s: MOVE TO %s" % [AI_level, check, current_pos])
		await get_tree().create_timer(4).timeout
	else:
		pass
		# print("BONNIE -- %s VS %s: STAY" % [AI_level, check])

# Based on current position, calculate the new position
# 0 - Spawn
# 1 - Point 8 (Room 7)
# 2 - Point 10 (Room 9)
# 3 - Point 11 (Hallway Front)
# 4 - Point 1D (Front Stairs Down)
# 5 - Point 3 (Room 3)
# 6 - Point LeftOffice (Left Office Door)
# 7 - Point J (Jumpscare/Hidden Position)
func find_new_destination(pos : int) -> int:
	rand.randomize()
	var dest : int = pos
	match pos:
		0:
			dest = rand.randi_range(1,3)
			if !game.getting_scared:
				emit_signal("bonnie_left_spawn")
		1:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 2
			else:
				dest = 3
		2: 
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 1
			else:
				dest = 3
		3:
			var chance = rand.randi_range(1,12)
			if chance <= 4:
				dest = 1
			elif chance <= 8:
				dest = 2
			else:
				dest = 4
		4:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 5
			else:
				dest = 6
				print("BONNIE -- AT DOOR")
		5:
			var chance = rand.randi_range(1,10)
			if chance <= 5:
				dest = 6
				print("BONNIE -- AT DOOR")
			else:
				dest = 4
		6:
			dest = attack()
			if dest == 7:
				emit_signal("jumpscare_bonnie")
			else:
				var check = rand.randi_range(1,2)
				enemy_sound.play_light_door_punch(check)
		_:
			dest = dest
	return dest

func attack() -> int:
	if game.left_door_close:
		print("BONNIE -- LEAVING")
		return 3
	return 7

func set_bonnie_position(pos : int) -> void:
	set_global_position(enemy_locations[pos].global_position)
	set_global_rotation(enemy_rotations[pos])

# Increase AI Level
func _on_clock_hour_change(hour):
	if (hour == 2 || hour == 3 || hour == 4) && enabled:
		AI_level += 1

func _on_enable_timer_timeout():
	enabled = true
	$EnableTimer.stop()
	print("Guac of Mole: Grace Period Over, %s" % enabled)

func _on_player_watching_camera_num(id):
	if camera_dict.has(id):
		if camera_dict[id] == current_pos:
			watching_current_position = true
	else:
		watching_current_position = false
