extends Control

var max_goal = 0 setget set_max_goal
var goal = 0 setget set_goal

onready var goalui = $Label

func set_goal(value):
	goal = clamp(value, 0, max_goal)
	goalui.text = "Goal: %s/%s" % [goal, max_goal]


func set_max_goal(value):
	max_goal = value
	goal = 0
	goalui.text = "Goal: %s/%s" % [goal, max_goal]
