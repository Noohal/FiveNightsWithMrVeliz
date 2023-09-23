extends Control

@onready var hour_label : Label = $"MarginContainer/VBoxContainer2/HBoxContainer/HourLabel"

var current_time : int

signal hour_change(hour : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_time = 0
	hour_label.text = "12AM"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_timer_timeout():
	if current_time == 6:
		return
	current_time = (current_time + 1) % 12
	print("NEXT HOUR")
	hour_label.text = str(current_time) + "AM"
	emit_signal("hour_change", current_time)
	
	if current_time == 7:
		# get_tree().quit()
		pass
	
