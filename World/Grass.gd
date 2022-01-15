extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

onready var stats = $Stats

func create_grass_effect():
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position


func _on_HurtBox_area_entered(area):
	create_grass_effect()
	stats.health -= area.Damage


func _on_Stats_no_health():
	queue_free()
