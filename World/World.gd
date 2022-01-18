extends Node2D

func _ready():
	randomize()
	var goal = $YSort/Grass.get_child_count()
	$CanvasLayer/PlayerGoalUI.max_goal = goal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
