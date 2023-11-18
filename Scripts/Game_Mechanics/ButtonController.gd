extends Node3D

@onready var left_door = $"LeftDoor"
@onready var right_door = $"RightDoor"

@onready var left_light = $"LightLeft"
@onready var left_outside_light = $"LightLeftOut"
@onready var right_light = $"LightRight"
@onready var right_outside_light = $"LightRightOut"

var can_use_buttons = true

var left_light_on = false
var right_light_on = false

var left_door_closed = false
var right_door_closed = false

signal left_light_change(active : bool)
signal right_light_change(active : bool)

func _ready():
	await get_parent().ready
	can_use_buttons = true
	
	left_light_on = false
	right_light_on = false
	left_door_closed = false
	right_door_closed = false
	
	$AmbientSound.volume_db = -20.0
	$AmbientSound.play()

func _process(_delta):
	if !can_use_buttons:
		return
	
	if left_light_on:
		if left_door_closed:
			left_light.light_energy = 0
			left_outside_light.light_energy = 1
		else:
			left_light.light_energy = 1
			left_outside_light.light_energy = 0
	else:
		left_light.light_energy = 0
		left_outside_light.light_energy = 0
	
	if right_light_on:
		if right_door_closed:
			right_light.light_energy = 0
			right_outside_light.light_energy = 1
		else:
			right_light.light_energy = 1
			right_outside_light.light_energy = 0
	else:
		right_light.light_energy = 0
		right_outside_light.light_energy = 0

func _on_door_button_left_input_event(_camera, event, _position, _normal, _shape_idx):
	if !can_use_buttons:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			left_door_closed = !left_door_closed
			if left_door_closed:
				left_door.door_close.play()
			else:
				left_door.door_open.play()
			left_door.toggle_door(left_door_closed)

func _on_door_button_right_input_event(_camera, event, _position, _normal, _shape_idx):
	if !can_use_buttons:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			right_door_closed = !right_door_closed
			if right_door_closed:
				right_door.door_close.play()
			else:
				right_door.door_open.play()
			right_door.toggle_door(right_door_closed)

func _on_light_button_left_input_event(_camera, event, _position, _normal, _shape_idx):
	if !can_use_buttons:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			$LightToggle.play()
			left_light_on = !left_light_on
			emit_signal("left_light_change", left_light_on)

func _on_light_button_right_input_event(_camera, event, _position, _normal, _shape_idx):
	if !can_use_buttons:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed == true:
			$LightToggle.play()
			right_light_on = !right_light_on
			emit_signal("right_light_change", right_light_on)

func _on_ambient_sound_finished():
	$AmbientSound.play()

func _on_power_power_loss():
	can_use_buttons = false
	left_light.light_energy = 0
	right_light.light_energy = 0
	left_outside_light.light_energy = 0
	right_outside_light.light_energy = 0
	
	if left_door_closed:
		left_door.door_open.play()
	left_door.toggle_door(false)
	if right_door_closed:
		right_door.door_open.play()
	right_door.toggle_door(false)
