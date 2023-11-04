extends Node

@export var audio : Array[AudioStreamPlayer]

var played_audio_for_night : bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.current_night >= audio.size():
		return
	
	if audio[Global.current_night].playing && Input.is_action_just_pressed("DisablePhoneGuy"):
		audio[Global.current_night].stop()
	
	if played_audio_for_night == false:
		await get_tree().create_timer(2.0).timeout
		
		played_audio_for_night = true
		audio[Global.current_night].play()
