extends Node3D

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var player_cam : Camera3D = $Camera3D
@onready var player_hud : Control = $PlayerHUD

var screen_size : Vector2

var start_angle : float = -90.0
var min_angle : float = -50.0
var max_angle : float = -130.0

var left_zone_end : float
var right_zone_start : float
var sens : float
var turn_speed : float

@export var camera_parent : Node3D
var cameras: Array[Camera3D]
var current_camera : int
var last_camera : int
var watching_camera : bool

signal watching_office
signal camera_state_change(watching : bool)
signal watching_camera_num(id : int)

signal looking_left

# Called when the node enters the scene tree for the first time.
func _ready():
	current_camera = 0
	last_camera = 1
	rotation.y = deg_to_rad(start_angle)
	screen_size = get_viewport().size
	left_zone_end = screen_size.x / 3
	right_zone_start = (screen_size.x / 3) + left_zone_end
	
	sens = screen_size.y / screen_size.x
	turn_speed = left_zone_end / screen_size.x
	
	watching_camera = false
	set_up_cameras()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if watching_camera == false:
		handle_camera_movement(delta)

func handle_camera_movement(delta) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x <= left_zone_end:
		mouse_pos.x = clamp(mouse_pos.x, (left_zone_end / 1.25), left_zone_end)
		rotate_y(deg_to_rad((left_zone_end - mouse_pos.x) * delta * sens + turn_speed))
		emit_signal("looking_left")
	elif mouse_pos.x >= right_zone_start:
		var res = right_zone_start + (screen_size.x - right_zone_start) * 0.3 - 10
		mouse_pos.x = clamp(mouse_pos.x, right_zone_start, res)
		rotate_y(deg_to_rad(-(mouse_pos.x - right_zone_start) * delta * sens - turn_speed))
	else:
		pass
	
	if rotation.y > deg_to_rad(min_angle):
		rotation.y = deg_to_rad(min_angle)
	elif rotation.y < deg_to_rad(max_angle):
		rotation.y = deg_to_rad(max_angle)

func set_up_cameras() -> void:
	cameras.append(player_cam)
	for i in camera_parent.get_children(false):
		cameras.append(i)

func toggle_camera() -> void:
	watching_camera = !watching_camera
	if watching_camera:
		anim.play("screen_up")
	else:
		anim.play("screen_down")
		last_camera = current_camera
		set_camera(0)
		player_hud.toggle_ui(false)
		emit_signal("watching_office")
		emit_signal("camera_state_change", false)

func set_camera(camera_id : int):
	for cam in cameras:
		var target_cam = "Cam%s" % camera_id
		if cam.name == target_cam:
			current_camera = camera_id
			cam.make_current()
		elif cam.current:
			cam.clear_current()
		else:
			pass # Do nothing
	emit_signal("watching_camera_num", camera_id)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "screen_up":
		current_camera = last_camera
		set_camera(current_camera)
		#emit_signal("watching_camera_num", current_camera)
		emit_signal("camera_state_change", true)
		player_hud.toggle_ui(true)
