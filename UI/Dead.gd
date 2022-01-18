extends Control

func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(get_tree().current_scene.filename)
	queue_free()
