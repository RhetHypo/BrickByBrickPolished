extends Control

#onready var tween = get_node("TransitionTween")
#onready var fadePanel = get_node("TransitionPanel")
onready var musicAudio = get_node("musicPlayer")
onready var titleLetters = get_node("TitleLetters")
#onready var tween = get_node("Tween")

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	random.randomize()
	if settings.music_enabled:
		musicAudio.volume_db = settings.music_level - 50
		musicAudio.play()
	get_node("Transition").fade_in()
	get_node("Camera2D/CanvasLayer/PauseDialog/MarginContainer/VBoxContainer/BackToMenu").visible = false
	alt_title_anim()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DelayTimer_timeout():
	$AnimationPlayer.play("Buttons")

func _on_SettingsButton_pressed():
	get_node("Camera2D/CanvasLayer/PauseDialog").popup_centered()


func _on_NewGameButton_pressed():
	get_node("Transition").switch_scene("res://scenes/levels/Gamefield.tscn")

func _on_HighscoresButton_pressed():
	get_node("Transition").switch_scene("res://scenes/menus/Highscores.tscn")


func _on_Quit_pressed():
	get_tree().quit()
	#should probably have a confirm dialog here

func alt_title_anim():
	titleLetters.rect_position.y = -1000
	titleLetters.visible = true
	var letter_array = []
	for child in titleLetters.get_node("HBoxContainer").get_children():
		letter_array.append(child)
	while !letter_array.empty():
		var index = random.randi_range(0,letter_array.size()-1)
		var child = letter_array[index]
		var tween = get_node("Tween")
		tween.interpolate_property(child, "rect_position:y", 0, 1000, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_completed")
		tween.interpolate_property(child, "rect_rotation", -30, 0, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween,"tween_completed")
		child.rect_position.y = 1000
		letter_array.remove(index)
