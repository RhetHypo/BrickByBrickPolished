extends Node

var music_enabled = true
var music_level = 1
var sound_enabled = true
var sound_level = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var settings_file = "user://settings.save"

func save_settings():
	var setFile = File.new()
	setFile.open(settings_file, File.WRITE)
	setFile.store_var(music_enabled)
	setFile.store_var(music_level)
	setFile.store_var(sound_enabled)
	setFile.store_var(sound_level)
	setFile.close()

func load_settings():
	var getFile = File.new()
	if getFile.file_exists(settings_file):
		getFile.open(settings_file, File.READ)
		music_enabled = getFile.get_var()
		music_level = getFile.get_var()
		sound_enabled = getFile.get_var()
		sound_level = getFile.get_var()
		getFile.close()