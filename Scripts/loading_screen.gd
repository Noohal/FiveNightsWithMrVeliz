extends CanvasLayer

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var time_label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/Time
@onready var night_label = $Panel/MarginContainer/HBoxContainer/VBoxContainer/Night

signal loading_screen_has_full_coverage

func _ready():
	time_label.text = "12:00AM"
	night_label.text = "Night %d" % (Global.current_night + 1)

func start_outro_animation() -> void:
	await get_tree().create_timer(0.1).timeout
	self.queue_free()
