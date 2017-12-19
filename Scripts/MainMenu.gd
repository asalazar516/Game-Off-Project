extends Panel

var style = StyleBoxFlat.new()

func _ready():
	add_style_override("Main Menu", style)
	pass

func _process(delta):
	var color = Color(0.5 * sin(OS.get_ticks_msec() / 100.0) +0.5, 0, 0)
	style.set_bg_color(color)
	update()

func _on_Play_Game_pressed():
	get_tree().change_scene("res://Game.xml")

func _on_How_To_Play_pressed():
	get_tree().change_scene("res://toPlay.xml")