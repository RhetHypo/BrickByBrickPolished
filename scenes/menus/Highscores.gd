extends Control

var scores_file = "user://hiscores.save"
var scores = []

const NAME = preload("res://scenes/menus/CustomName.tscn")
const SCORE = preload("res://scenes/menus/CustomScore.tscn")

onready var grid = get_node("VBoxContainer/GridContainer")

func _ready():
	if globals.endgame:
		get_node("NewHighscore").popup_centered()
	get_node("VBoxContainer/HBoxContainer/Medium").grab_focus()
	load_scores()
	display_scores()

func display_scores():
	var index = 0
	for score in scores:
		index += 1
		var newIndex = NAME.instance()
		newIndex.text = str(index)
		grid.add_child(newIndex)
		var newName = NAME.instance()
		newName.text = score[0]
		grid.add_child(newName)
		var newScore = SCORE.instance()
		newScore.text = score[1]
		grid.add_child(newScore)
		var newspacer = NAME.instance()
		newspacer.text = ""
		grid.add_child(newspacer)

func load_scores():
	var getFile = File.new()
	if getFile.file_exists(scores_file):
		getFile.open(scores_file, File.READ)
		scores = getFile.get_var()
		getFile.close()
		print("found score")
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
	print(scores)
	scores.insert(position,[new_text.to_upper(),globals.endgame_score])
	scores.pop_back()
	print(scores)
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
