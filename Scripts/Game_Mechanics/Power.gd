extends Control

@onready var power_label : Label = $"MarginContainer/VBoxContainer/HBoxContainer/PowerLevel"
@onready var usage_label : Label = $"MarginContainer/VBoxContainer/UsageLabel"

var power_usage : int = 1
var power_level : float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	power_usage = 1
	power_level = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	power_level -= delta * power_usage * 0.2
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
