extends Node3D

var screen_size : Vector2

var left_zone_end : float
var right_zone_start : float
var sens : float
var turn_speed : float

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation.y = deg_to_rad(-90.0)
	screen_size = get_viewport().size
	left_zone_end = screen_size.x / 3
	right_zone_start = (screen_size.x / 3) + left_zone_end
	
	sens = screen_size.y / screen_size.x
	turn_speed = left_zone_end / screen_size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x <= left_zone_end:
		mouse_pos.x = clamp(mouse_pos.x, (left_zone_end / 1.2), left_zone_end)
		rotate_y(deg_to_rad((left_zone_end - mouse_pos.x) * delta * sens + turn_speed))
	elif mouse_pos.x >= right_zone_start:
		var res = right_zone_start + (screen_size.x - right_zone_start) * 0.3 - 10
		mouse_pos.x = clamp(mouse_pos.x, right_zone_start, res)
		rotate_y(deg_to_rad(-(mouse_pos.x - right_zone_start) * delta * sens - turn_speed))
	else:
		print(rad_to_deg(rotation.y))
	
	if rotation.y > deg_to_rad(-50.0):
		rotation.y = deg_to_rad(-50.0)
	elif rotation.y < deg_to_rad(-130.0):
		rotation.y = deg_to_rad(-130.0)
		
