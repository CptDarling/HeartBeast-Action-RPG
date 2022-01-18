extends Control

func _on_Button_pressed():
	get_tree().change_scene(get_tree().current_scene.filename)
	queue_free()
