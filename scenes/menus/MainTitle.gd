extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	$DelayTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DelayTimer_timeout():
	$AnimationPlayer.play("Title")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Title":
		$AnimationPlayer.play("Buttons")


func _on_SettingsButton_pressed():
	get_node("PauseDialog").popup_centered()
