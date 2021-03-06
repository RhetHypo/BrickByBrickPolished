extends PopupDialog

onready var actual_parent = get_parent().get_parent().get_parent()
onready var musicAudio = actual_parent.get_node("musicPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	settings.load_settings()
	update_settings()

func update_settings():
	var pause_settings = get_node("MarginContainer/VBoxContainer")
	pause_settings.get_node("MusicHSlider").value = settings.music_level
	pause_settings.get_node("SoundHSlider").value = settings.sound_level
	pause_settings.get_node("Music").pressed = settings.music_enabled
	pause_settings.get_node("Sound").pressed = settings.sound_enabled
	pause_settings.get_node("ControlOptions").selected = settings.control_scheme
	pause_settings.get_node("GraphicsOptions").selected = settings.graphics
	pause_settings.get_node("DifficultyOptions").selected = settings.difficulty
	settings.save_settings()

func _on_Music_pressed():
	settings.music_enabled = !settings.music_enabled
	update_settings()
	if settings.music_enabled:
		musicAudio.play()
	else:
		musicAudio.stop()


func _on_MusicHSlider_value_changed(value):
	settings.music_level = value
#	if value > 0:
#		settings.music_enabled = true
#	else:
#		settings.music_enabled = false
	musicAudio.volume_db = settings.music_level - 50
	update_settings()


func _on_Sound_pressed():
	settings.sound_enabled = !settings.sound_enabled
	update_settings()


func _on_SoundHSlider_value_changed(value):
	settings.sound_level = value
#	if value > 0:
#		settings.sound_enabled = true
#	else:
#		settings.sound_enabled = false
	update_settings()

func _on_ControlOptions_item_selected(ID):
	settings.control_scheme = ID
	update_settings()


func _on_GraphicsOptions_item_selected(ID):
	settings.graphics = ID
	update_settings()


func _on_DifficultyOptions_item_selected(ID):
	settings.difficulty = ID
	update_settings()


func _on_BackToMenu_pressed():
	get_tree().paused = false
	actual_parent.get_node("Transition").switch_scene("res://scenes/menus/MainTitle.tscn")
