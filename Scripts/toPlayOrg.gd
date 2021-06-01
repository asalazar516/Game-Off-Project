extends Panel

func _ready():
	pass

func _on_ReturnToMainMenu_pressed():
	get_tree().change_scene("res://Scenes/mainMenu.tscn")

