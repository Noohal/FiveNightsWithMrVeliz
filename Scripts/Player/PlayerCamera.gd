extends Node3D

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var player_cam : Camera3D = $Camera3D
@onready var player_hud : Control = $"PlayerHUD"
@onready var camera_location : Label = $"PlayerHUD/MarginContainer/HBoxContainer/ButtonMap/Room"

@export var camera_rooms : Array[String]

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
var watching_cams : bool

var can_look_at_camera : bool = true

signal watching_camera
signal watching_office
signal watching_camera_num(id : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	current_camera = 0
	last_camera = 1
	rotation.y = deg_to_rad(start_angle)
	screen_size = get_viewport().size
	left_zone_end = screen_size.x / 3
	right_zone_start = (screen_size.x / 3) + left_zone_end + 512
	
	sens = screen_size.y / screen_size.x
	turn_speed = left_zone_end / screen_size.x
	
	watching_cams = false
	set_up_cameras()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if watching_cams == false:
		handle_camera_movement(delta)

func handle_camera_movement(delta) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x <= left_zone_end:
		mouse_pos.x = clamp(mouse_pos.x, (left_zone_end / 1.25), left_zone_end)
		rotate_y(deg_to_rad((left_zone_end - mouse_pos.x) * delta * sens + turn_speed))
	elif mouse_pos.x >= right_zone_start:
		mouse_pos.x = clamp(mouse_pos.x, right_zone_start, (right_zone_start * 1.1))
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
	if !can_look_at_camera:
		print("NO CAMERAS!")
		return
	watching_cams = !watching_cams
	if watching_cams:
		$"ToggleCameras".play()
		anim.play("screen_up")
		await anim.animation_finished
		watching_camera.emit()
	else:
		turn_off_cameras()

func turn_off_cameras() -> void:
	anim.play("screen_down")
	$"ToggleCameras".play()
	last_camera = current_camera
	set_camera(0)
	player_hud.toggle_ui(false)
	watching_office.emit()

func set_camera(camera_id : int):
	if current_camera != camera_id:
		$"SwitchCams".play()
	for cam in cameras:
		var target_cam = "Cam%s" % camera_id
		if cam.name == target_cam:
			current_camera = camera_id
			camera_location.text = camera_rooms[camera_id - 1]
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
		player_hud.toggle_ui(true)

func _on_node_3d_getting_killed():
	can_look_at_camera = false

func _on_power_power_loss():
	watching_cams = false
	can_look_at_camera = false
