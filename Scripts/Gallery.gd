extends Control

@onready var melvinzord = $MarginContainer/HBoxContainer/VBoxContainer/Buttons/VBoxContainer/Melvinzord
@onready var roundbus = $MarginContainer/HBoxContainer/VBoxContainer/Buttons/VBoxContainer/Roundbus
@onready var hoombus = $MarginContainer/HBoxContainer/VBoxContainer/Buttons/VBoxContainer/Hoombus
@onready var stonedome = $MarginContainer/HBoxContainer/VBoxContainer/Buttons/VBoxContainer/Stonedome
@onready var golden = $MarginContainer/HBoxContainer/VBoxContainer/Buttons/VBoxContainer/golden


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Next Night to Play: Night %s" % (Global.max_night+1))
	match Global.max_night:
		0,1:
			melvinzord.text = "???"
			roundbus.text = "Roundvin"
			hoombus.text = "Hoombus"
			stonedome.text = "???"
			golden.text = "???"
		2:
			melvinzord.text = "???"
			roundbus.text = "Roundvin"
			hoombus.text = "Hoombus"
			stonedome.text = "Stonedome"
			golden.text = "???"
		3,4,5:
			melvinzord.text = "Melvinzord"
			roundbus.text = "Roundvin"
			hoombus.text = "Hoombus"
			stonedome.text = "Stonedome"
			golden.text = "???"
		_:
			melvinzord.text = "Melvinzord"
			roundbus.text = "Roundvin"
			hoombus.text = "Hoombus"
			stonedome.text = "Stonedome"
			golden.text = "3B9 VT6P4PYN8"
			pass

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Menu.tscn")
