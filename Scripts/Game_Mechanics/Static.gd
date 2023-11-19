extends Control

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var texture : TextureRect = $"1"

func _ready():
	texture.visible = false

func _on_cabron_chica_movement():
	animation_player.play("play_static")

func _on_shashumga_bonnie_moving():
	animation_player.play("play_static")
