extends Panel

func _ready():
	pass

func _on_Play_Game_pressed():
	get_tree().change_scene("res://Scenes/Game.xml")

func _on_How_To_Play_pressed():
	get_tree().change_scene("res://Scenes/toPlay.xml")