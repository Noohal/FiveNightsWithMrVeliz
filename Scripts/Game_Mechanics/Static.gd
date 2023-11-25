extends Control

@export var player_cam : Node3D

@onready var game = $"../../../"
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var const_static : AnimationPlayer = $ConstantStatic
@onready var texture : TextureRect = $"1"

var current_camera : int = 0

func _ready():
	await game.ready
	texture.visible = false
	const_static.get_animation("ambient").loop_mode = Animation.LOOP_LINEAR
	const_static.play("ambient")

func _on_cabron_chica_movement():
	animation_player.play("play_static")

func _on_shashumga_bonnie_moving(_old : int, _newLoc : int):
	#game.night_label.text = "Current: %s, New: %s" % [cached_current, newLoc]
	animation_player.play("play_static")
