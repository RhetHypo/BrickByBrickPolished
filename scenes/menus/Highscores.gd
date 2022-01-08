extends Control

var scores_file = "user://hiscores.save"
var scores = []

const NAME = preload("res://scenes/menus/CustomName.tscn")
const SCORE = preload("res://scenes/menus/CustomScore.tscn")

onready var grid = get_node("VBoxContainer/GridContainer")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if globals.endgame:
		get_node("NewHighscore").popup_centered()
	globals.endgame = false
	get_node("VBoxContainer/HBoxContainer/Medium").grab_focus()
	load_scores()
	display_scores()
	get_node("Transition").fade_in()

func display_scores():
	var index = 0
	for child in grid.get_children():
		if !child.is_in_group("Label"):
			child.queue_free()
	for score in scores:
		index += 1
		var newIndex = NAME.instance()
		newIndex.text = str(index)
		grid.add_child(newIndex)
		var newName = NAME.instance()
		newName.text = score[0]
		grid.add_child(newName)
		var newScore = SCORE.instance()
		newScore.text = str(score[1])
		grid.add_child(newScore)
		var newspacer = NAME.instance()
		newspacer.text = ""
		grid.add_child(newspacer)

func load_scores():
	var getFile = File.new()
	if getFile.file_exists(scores_file):
		getFile.open(scores_file, File.READ)
		for j in range(len(scores),10):
			var player = getFile.get_var()
			var score = getFile.get_var()
			scores.append([player, score])
	getFile.close()
	if len(scores) < 10:
		for i in range(len(scores),10):
			print("generating score")
			scores.append(["AAA", "0"])
	#should load existing scores, and fill in nonexisting ones if there are less than ten

func save_score(new_text):
	var position = 0
	for score in scores:
		if int(score[1]) < globals.endgame_score:
			break
		else:
			position += 1
	scores.insert(position,[new_text.to_upper(),globals.endgame_score])
	scores.pop_back()
	var setFile = File.new()
	setFile.open(scores_file, File.WRITE)
	for k in range(0,len(scores)):
		setFile.store_var(scores[k][0])
		setFile.store_var(scores[k][1])
	setFile.close()
	display_scores()
	#should 
	#1. get current scores, DONE
	#2. find if the new one is a high score, 
	#3. prompt for name to enter(three characters for now), DONE
	#4. place at proper point in list by removing the last item, and inserting in last spot


func _on_Easier_pressed():
	pass # Replace with function body.


func _on_Medium_pressed():
	pass # Replace with function body.


func _on_Harder_pressed():
	pass # Replace with function body.


func _on_LineEdit_text_entered(new_text):
	print(new_text)
	get_node("NewHighscore").hide()
	save_score(new_text)


func _on_BackButton_pressed():
	get_node("Transition").switch_scene("res://scenes/menus/MainTitle.tscn")
