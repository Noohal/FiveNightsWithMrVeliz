extends Node3D

@onready var game : Node3D = $"../"

@export var enabled : bool
@export var enemy_locations : Array[Node3D]
@export var enemy_rotations: Array[Vector3]
@export var night_AI_levels : Array[int]

@onready var anim = $CabronPlayer
@onready var enemy_sound = $EnemySound

# Maps CamerasEnum to enemy location index
@onready var camera_dict = {
	9: 0,
	11: 1,
	8: 2,
	2: 3,
	4: 4,
	5: 5
}

var rand = RandomNumberGenerator.new()

var AI_level : int
var current_pos : int
var next_pos : int
const MOVEMENT_INTERVAL : float = 4.8

var watching_current_position : bool = false

const FIRST_NIGHT_GRACE_PERIOD_TIMER : float = 160.0
const LATER_NIGHT_GRACE_PERIOD_TIMER : float = 30.0

signal chica_left_spawn
signal chica_movement
signal jumpscare_chica

func _ready():
	await game.ready
	anim.play("propellorhat")
	if !enabled:
		return
	
	enabled = false
	if Global.current_night < 1:
		$EnableTimer.wait_time = FIRST_NIGHT_GRACE_PERIOD_TIMER
	else:
		var grace_period = LATER_NIGHT_GRACE_PERIOD_TIMER - 10.0 * (Global.current_night - 1)
		if grace_period <= 0.0:
			grace_period = 1.0
		$EnableTimer.wait_time = grace_period
	
	print("Hoombus: Grace Period %f, %s" % [$EnableTimer.wait_time, enabled])
	$EnableTimer.start()
	
	rand.randomize()
	AI_level = night_AI_levels[game.current_night]
	current_pos = 0
	next_pos = current_pos + 1
	set_chica_position(6)

# Check Movement Opportunity
func _on_timer_timeout():
	if !enabled:
		return
	
	if current_pos == 7:
		return
	
	rand.randomize()
	var check = rand.randi_range(1,20)
	if AI_level >= check:
		next_pos = find_new_destination(current_pos)
		if watching_current_position:
			print("CHICA -- PLAYING STATIC")
			emit_signal("chica_movement")
		await get_tree().create_timer(0.25).timeout
		current_pos = next_pos
		set_chica_position(current_pos)
		print("CHICA -- %s VS %s: MOVE TO %s" % [AI_level, check, current_pos])
		await get_tree().create_timer(4).timeout
	else:
		#print("CHICA -- %s VS %s: STAY" % [AI_level, check])
		pass

func find_new_destination(pos : int) -> int:
	rand.randomize()
	var dest = pos
	match pos:
		0:
			dest = 1
			emit_signal("chica_left_spawn")
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
			var chance = rand.randi_range(1,10)
			if chance <= 2:
				dest = 1
			else:
				dest = 4
		4:
			var chance = rand.randi_range(1,10)
			if chance <= 3:
				dest = 5
			else:
				dest = 6
		5:
			dest = 6
			print("CHICA -- AT DOOR")
		6:
			dest = attack()
			if dest == 7 && !game.getting_scared:
				emit_signal("jumpscare_chica")
				set_global_rotation(Vector3(0,deg_to_rad(-180.0),0))
			else:
				var check = rand.randi_range(1,2)
				enemy_sound.play_light_door_punch(check)
		_:
			dest = dest
	return dest

func attack() -> int:
	if game.right_door_close:
		print("LEAVING")
		return 3
	return 7

func set_chica_position(pos : int) -> void:
	set_global_position(enemy_locations[pos].global_position)
	set_global_rotation(enemy_rotations[pos])

func _on_clock_hour_change(hour):
	if (hour == 3 || hour == 4) && enabled:
		AI_level += 1

func _on_enable_timer_timeout():
	enabled = true
	$EnableTimer.stop()
	print("Hoombus: Grace Period Over, %s" % enabled)

func _on_player_watching_camera_num(id):
	if camera_dict.has(id):
		if camera_dict[id] == current_pos || camera_dict[id] == next_pos:
			watching_current_position = true
		# watching_current_position = true
	else:
		watching_current_position = false
