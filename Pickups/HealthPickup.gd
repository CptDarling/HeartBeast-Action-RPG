extends Area2D

export var extra_lives = 1

var HealthPickupSound = preload("res://Pickups/HealthPickupSound.tscn")

func _ready():
	$AnimationPlayer.play("Bob")

func _on_HealthPickup_body_entered(body):
	if body.has_method("add_health"):
		body.add_health(extra_lives)
		var health_pickup_sound = HealthPickupSound.instance()
		get_tree().current_scene.add_child(health_pickup_sound)
		queue_free()
