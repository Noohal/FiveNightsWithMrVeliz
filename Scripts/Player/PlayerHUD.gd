extends Control

@onready var pc_panel_toggle = $MarginContainer/VBoxContainer/PCPanelToggle

@onready var player : Node3D = $"../"
@onready var map : Node2D = $"MarginContainer/HBoxContainer/ButtonMap"
@onready var downstairs : Node2D = $"MarginContainer/HBoxContainer/ButtonMap/DownstairsMap"
@onready var upstairs : Node2D= $"MarginContainer/HBoxContainer/ButtonMap/UpstairsMap"
@onready var toggle_label = $MarginContainer/HBoxContainer/ButtonMap/Toggle/ToggleLabel

var playing_animation : bool = false
var looking_upstairs : bool = false

func _ready():
	looking_upstairs = false
	hide_upstairs()
	toggle_ui(false)

func toggle_ui(enable : bool) -> void:
	if enable:
		map.show()
	else:
		map.hide()

func hide_upstairs() -> void:
	looking_upstairs = true
	toggle_upstairs()

func toggle_upstairs() -> void:
	looking_upstairs = !looking_upstairs
	if looking_upstairs:
		toggle_label.text = "Toggle\nDownstairs"
		downstairs.hide()
		upstairs.show()
	else:
		toggle_label.text = "Toggle\nUpstairs"
		downstairs.show()
		upstairs.hide()

func _on_animation_player_animation_started(_anim_name):
	# print("STARTING " + anim_name)
	playing_animation = true

func _on_animation_player_animation_finished(_anim_name):
	# print(anim_name + " FINISHED")
	playing_animation = false

func _on_texture_rect_mouse_entered():
	if playing_animation == false:
		player.toggle_camera()
