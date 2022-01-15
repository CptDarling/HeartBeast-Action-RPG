extends Node2D

onready var stats = $Stats

func create_grass_effect():
	var GrassEffect = load("res://Effects/GrassEffect.tscn")
	var grassEffect = GrassEffect.instance()
	var world = get_tree().current_scene
	world.add_child(grassEffect)
	grassEffect.global_position = global_position


func _on_HurtBox_area_entered(area):
	create_grass_effect()
	stats.health -= area.Damage


func _on_Stats_no_health():
	queue_free()
