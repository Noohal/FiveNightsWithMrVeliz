extends Node3D

var current_door = -1
var close_door = false
@onready var anim = $AnimationPlayer
@onready var mesh = $"."

func _ready():
	var starting_angle = 0
	if name == "LeftDoor":
		starting_angle = -120
		current_door = 0
	elif name == "RightDoor":
		starting_angle = -60
		current_door = 1
	else:
		current_door = -1
	rotate(Vector3(0,1,0), deg_to_rad(starting_angle))
	close_door = true

func toggle_left_door() -> void:
	close_door = !close_door
	if close_door:
		#print("OPENING DOOR %s" % current_door)
		anim.play("door_open_left")
	else:
		#print("CLOSING DOOR %s" % current_door)
		anim.play("door_close_left")

func toggle_right_door() -> void:
	close_door = !close_door
	if close_door:
		#print("OPENING DOOR %s" % current_door)
		anim.play("door_open_right")
	else:
		#print("CLOSING DOOR %s" % current_door)
		anim.play("door_close_right")
