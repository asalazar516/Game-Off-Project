extends CenterContainer

var style = StyleBoxFlat.new()

func _ready():
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
#	add_style_override("Main Menu", style)
	pass
	
func _process(delta):
	var color = Color(0.5 * sin(OS.get_ticks_msec() / 100.0) +0.5, 0, 0)
	style.set_bg_color(color)
	update()

func _on_PlayGame_pressed():
	get_tree().change_scene("res://Scenes/Game.tscn")


func _on_HowTo_pressed():
	get_tree().change_scene("res://Scenes/toPlayOrg.tscn")

