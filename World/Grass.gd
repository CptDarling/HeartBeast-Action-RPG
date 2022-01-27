extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")
const Bat = preload("res://Mobs/Bat.tscn")

export(float) var chance_of_bat = 0.5

onready var stats = $Stats

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position


func _on_HurtBox_area_entered(area):
	create_grass_effect()
	stats.health -= area.Damage


func _on_Stats_no_health():
	if rand_range(0.0, 1.0) <= chance_of_bat:
		var bat = Bat.instance()
		bat.global_position = global_position
		get_tree().current_scene.get_node("YSort/Enemies").call_deferred("add_child", bat)
	get_tree().current_scene.get_node("CanvasLayer/PlayerGoalUI").goal += 1
	queue_free()
