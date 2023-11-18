extends Node3D

@onready var anim = $AnimationPlayer
@onready var mesh = $"."
@onready var door_open : AudioStreamPlayer = $"../DoorOpen"
@onready var door_close : AudioStreamPlayer = $"../DoorClose"

var current_door = -1

var can_open_door : bool

signal left_door_change(active : bool)
signal right_door_change(active : bool)

func _ready():
	can_open_door = true
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

func toggle_door(close : bool) -> void:
	if !can_open_door:
		return
	if !close:
		open_door()
	else:
		close_door()

func open_door() -> void:
	if current_door == 1:
		anim.play("door_open_right")
		emit_signal("right_door_change", false)
		#door_open.play()
	elif current_door == 0:
		anim.play("door_open_left")
		emit_signal("left_door_change", false)
		#door_open.play()
	else:
		print("Invalid Door Open")
		return

func close_door() -> void:
	if current_door == 1:
		anim.play("door_close_right")
		emit_signal("right_door_change", true)
		#door_close.play()
	elif current_door == 0:
		anim.play("door_close_left")
		emit_signal("left_door_change", true)
		#door_close.play()
	else:
		print("Invalid Door Close")
		return
