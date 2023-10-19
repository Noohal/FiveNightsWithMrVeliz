extends Node3D

@onready var anim = $AnimationPlayer
@onready var mesh = $"."
@onready var door_open : AudioStreamPlayer = $"../DoorOpen"
@onready var door_close : AudioStreamPlayer = $"../DoorClose"

var current_door = -1
var open_door = false

signal left_door_change(active : bool)
signal right_door_change(active : bool)

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
	open_door = true

func toggle_left_door() -> void:
	open_door = !open_door
	if open_door:
		#print("OPENING DOOR %s" % current_door)
		anim.play("door_open_left")
		emit_signal("left_door_change", false)
		door_open.play()
	else:
		#print("CLOSING DOOR %s" % current_door)
		anim.play("door_close_left")
		emit_signal("left_door_change", true)
		door_close.play()

func toggle_right_door() -> void:
	open_door = !open_door
	if open_door:
		#print("OPENING DOOR %s" % current_door)
		anim.play("door_open_right")
		emit_signal("right_door_change", false)
		door_open.play()
	else:
		#print("CLOSING DOOR %s" % current_door)
		anim.play("door_close_right")
		emit_signal("right_door_change", true)
		door_close.play()
