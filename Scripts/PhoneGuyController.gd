extends Node

@export var audio : Array[AudioStreamPlayer]

var current_player : AudioStreamPlayer
var played_audio_for_night : bool = false

func _ready():
	if Global.current_night < audio.size():
		current_player = audio[Global.current_night]
		played_audio_for_night = false
	else:
		played_audio_for_night = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if played_audio_for_night:
		return
	
	if current_player.playing && Input.is_action_just_pressed("DisablePhoneGuy"):
		current_player.stop()
	
	if played_audio_for_night == false:
		await get_tree().create_timer(2.0).timeout
		
		played_audio_for_night = true
		current_player.play()

func _on_power_power_loss():
	if audio[Global.current_night].playing:
		audio[Global.current_night].stop()
