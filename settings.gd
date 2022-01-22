extends Node

var music_enabled = true
var music_level = 100
var sound_enabled = true
var sound_level = 100
var control_scheme = 0
var graphics = 0
var difficulty = 0
var settings_file = "user://settings.save"
var expected_vars = 7

var color_defs = {"WHITE": Color(1,1,1,1), "RED": Color(1,0,0,1), "BLUE": Color(0,0,1,1), "YELLOW": Color(1,1,0,1), "GREEN": Color(0,1,0,1), "MAGENTA": Color(1,0,1,1), "VIOLET": Color(.7,0,.7,1), "ORANGE": Color(1,.5,.1,1), "BLACK": Color(0,0,0,1)}
var color_queue = ["WHITE", "BLUE", "MAGENTA", "RED", "ORANGE", "YELLOW", "GREEN"]

func _ready():
	pass

func save_settings():
	var setFile = File.new()
	setFile.open(settings_file, File.WRITE)
	setFile.store_var(music_enabled)
	setFile.store_var(music_level)
	setFile.store_var(sound_enabled)
	setFile.store_var(sound_level)
	setFile.store_var(control_scheme)
	setFile.store_var(graphics)
	setFile.store_var(difficulty)
	setFile.close()

func load_settings():
	var getFile = File.new()
	if getFile.file_exists(settings_file):
		getFile.open(settings_file, File.READ)
		var temp_settings = []
		var bad_settings = false
		for i in range(0,expected_vars):
			var temp_setting = getFile.get_var()
			if temp_setting != null:
				temp_settings.append(temp_setting)
			else:
				bad_settings = true
				break
		if !bad_settings:
			music_enabled = temp_settings[0]
			music_level = temp_settings[1]
			sound_enabled = temp_settings[2]
			sound_level = temp_settings[3]
			control_scheme = temp_settings[4]
			graphics = temp_settings[5]
			difficulty = temp_settings[6]
		getFile.close()