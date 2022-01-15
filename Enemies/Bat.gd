extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var WANDER_TARGET_PROXIMITY = 1

enum State {
	IDLE,
	WANDER,
	CHASE,
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = State.CHASE setget set_state

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var hurtbox = $HurtBox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController
onready var thought_bubble = $ThoughtBubble

func _ready():
	sprite.frame = rand_range(0, sprite.frames.get_frame_count("Fly"))
	sprite.play()
	self.state = pick_random_state([State.IDLE, State.WANDER])


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		State.IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			if wander_controller.get_time_left() == 0:
				choose_state()
			
		State.WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0 or global_position.distance_squared_to(wander_controller.target_position) <= WANDER_TARGET_PROXIMITY:
				choose_state()
				
			accelerate_towards_point(wander_controller.target_position, delta)
			
		State.CHASE:
			var player = player_detection_zone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				self.state = State.IDLE

	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * 400 * delta

	velocity = move_and_slide(velocity)


func set_state(value):
	state = value
	thought_bubble.set_text(State.keys()[state])

func accelerate_towards_point(point : Vector2, delta : float):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0


func choose_state():
	self.state = pick_random_state([State.IDLE, State.WANDER])
	wander_controller.start_wander_timer(rand_range(1, 3))


func seek_player() -> void:
	if player_detection_zone.can_see_player():
		self.state = State.CHASE


func pick_random_state(state_list : Array) -> int:
	state_list.shuffle()
	return state_list.pop_front()


func _on_HurtBox_area_entered(area : Area2D):
	stats.health -= area.Damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
