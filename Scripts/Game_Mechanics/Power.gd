extends Control

@onready var power_label : Label = $"MarginContainer/VBoxContainer/HBoxContainer/PowerLevel"
@onready var usage_label : Label = $"MarginContainer/VBoxContainer/UsageLabel"

var power_usage : int = 1
var power_level : float = 100

const start_usage_drain_time : float = 9.6
var last_usage_time : float = 0.0
var usage_drain_time : float = 9.6

const start_usage_constant_time : float = 9.6
var last_constant_time : float = 0.0
var constant_drain_time : float = 7.0

signal power_loss

# Called when the node enters the scene tree for the first time.
func _ready():
	constant_drain_time -= (Global.current_night)
	constant_drain_time = 0.0 if Global.current_night == 0.0 else constant_drain_time
	#print("Current Night Drain interval: %d" % constant_drain_time)
	if constant_drain_time <= 3.0:
		constant_drain_time = 3.0
	power_usage = 1
	power_level = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var current_time = Time.get_unix_time_from_system()
	
	if power_level <= 0:
		return
	
	if power_usage < 1:
		power_usage = 1
	elif power_usage > 5:
		power_usage = 5
	
	# Lose 1% Power every:
	# --> Usage 1 - 9.6/1 = 9.6 seconds
	# --> Usage 2 - 9.6/2 = 4.8 seconds
	# --> Usage 3 - 9.6/4 = 2.4 seconds
	# --> Usage 5 - 9.6/8 = 1.2 seconds
	# --> Usage 4 - 9.6/8 = 1.2 seconds
	
	if current_time - last_constant_time >= constant_drain_time && Global.current_night > 0:
		var cons = 1.0
		#print("Constant Drain %.02f: %.02f - %.02f = %.02f" % [constant_drain_time, power_level, cons, power_level - 1.0])
		power_level -= cons
		last_constant_time = current_time
	
	if current_time - last_usage_time >= usage_drain_time:
		var cons = 10.0
		#print("Usage Drain %.02f: %.02f - %.02f = %.02f" % [usage_drain_time, power_level, cons, power_level - 1.0])
		power_level -= cons
		last_usage_time = current_time
	
	power_label.text = "Power: %d%%" % power_level
	usage_label.text = "Usage: %s" % (power_usage)
	
	if power_level <= 0.0:
		emit_signal("power_loss")
		return

func update_power_usage():
	usage_drain_time = start_usage_drain_time / clampf(2.0 ** (power_usage - 1), 1, 8)
	usage_drain_time = clampf(usage_drain_time, 1.2, 9.6)

func _on_left_door_left_door_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1
		
	update_power_usage()

func _on_right_door_right_door_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1
	update_power_usage()


func _on_office_left_light_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1
	update_power_usage()

func _on_office_right_light_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1
	update_power_usage()

func _on_stonedome_drain_power(amount):
	power_level -= amount
	print("FOXY -- POWER DRAINED BY %d%%" % amount)

func _on_player_camera_state_change(watching):
	if watching:
		power_usage += 1
	else:
		power_usage -= 1
	update_power_usage()
