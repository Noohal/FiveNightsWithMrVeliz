extends Node3D

@onready var left_door = $"LeftDoor"
@onready var right_door = $"RightDoor"
@onready var left_light = $"LightLeft"
@onready var right_light = $"LightRight"

var left_light_on = false
var right_light_on = false

func _process(_delta):
	if left_light_on:
		left_light.light_energy = 1
	else:
		left_light.light_energy = 0
	
	if right_light_on:
		right_light.light_energy = 1
	else:
		right_light.light_energy = 0

func _on_door_button_left_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			left_door.toggle_left_door()


func _on_door_button_right_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			right_door.toggle_right_door()


func _on_light_button_left_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			left_light_on = !left_light_on


func _on_light_button_right_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			right_light_on = !right_light_on
