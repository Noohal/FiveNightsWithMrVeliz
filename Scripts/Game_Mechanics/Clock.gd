extends Control

@onready var hour_label : Label = $"MarginContainer/VBoxContainer/HourLabel"
@onready var countdown_label : Label = $"MarginContainer/VBoxContainer/Label"

var current_time : int
var night_one_length : float = 70.0
var hour_interval : float = 80.0
var time_left : float

signal hour_change(hour : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_time = 0
	$Timer.wait_time = night_one_length if Global.current_night == 0 else hour_interval
	$Timer.start()
	time_left = hour_interval
	hour_label.text = "12AM"
	countdown_label.text = str(time_left)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_left -= delta
	countdown_label.text = "%.02f" % time_left

func _on_timer_timeout():
	current_time = (current_time + 1) % 12
	
	if current_time == 6:
		get_tree().change_scene_to_file("res://Scenes/NightClear.tscn")
		return
	
	hour_label.text = str(current_time) + "AM"
	emit_signal("hour_change", current_time)
	time_left = hour_interval
