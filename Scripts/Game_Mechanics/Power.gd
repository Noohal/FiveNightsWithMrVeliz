extends Control

@onready var power_label : Label = $"MarginContainer/VBoxContainer/HBoxContainer/PowerLevel"
@onready var usage_label : Label = $"MarginContainer/VBoxContainer/UsageLabel"

var power_usage : int = 1
var power_level : float = 100

var last_time : float = 0.0
var drain_time : float = 1
var drain_rate : float = 9.6

signal power_loss

# Called when the node enters the scene tree for the first time.
func _ready():
	power_usage = 1
	power_level = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_time = Time.get_unix_time_from_system()	
	var power_decrease : float = (drain_rate * 10) * (1.0 / (float)(2**(power_usage - 1)))
	
	if current_time - last_time >= drain_time:
		#print("%.02f - %.02f = %.02f" % [power_level, power_decrease, power_level - power_decrease])
		power_level -= power_decrease
		last_time = current_time
	
	if power_level <= 0.0:
		emit_signal("power_loss")
		return
	
	power_label.text = "Power: %d%%" % power_level
	usage_label.text = "Usage: %s" % (power_usage)

func _on_player_camera_state_change(watching):
	if watching:
		power_usage += 1
	else:
		power_usage -= 1

func _on_left_door_left_door_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1


func _on_right_door_right_door_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1


func _on_office_left_light_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1


func _on_office_right_light_change(active):
	if active:
		power_usage += 1
	else:
		power_usage -= 1


func _on_stonedome_drain_power(amount):
	power_level -= amount
	print("FOXY -- POWER DRAINED BY %d%%" % amount)
