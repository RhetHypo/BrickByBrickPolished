extends Control

onready var tween = self.get_node("TransitionTween")
onready var panel = self.get_node("TransitionPanel")


func switch_scene(new_scene):
	self.visible = true
	tween.interpolate_property(panel, "modulate:a", 0, 1, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween,"tween_completed")
	get_tree().change_scene(new_scene)

func fade_in():
	self.visible = true
	tween.interpolate_property(panel, "modulate:a", 1, 0, 1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	self.visible = false