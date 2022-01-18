extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
const Dead = preload("res://UI/Dead.tscn")

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500
export var INVINCIBLE = 0.5

enum State {
	MOVE,
	ROLL,
	ATTACK,
	KILLED,
	DEAD
}

var state = State.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

var stats = PlayerStats

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitBox
onready var hurtbox = $HurtBox
onready var blink_animation_player = $BlinkAnimationPlayer

func _ready():
	stats.connect("no_health", self, "killed")
	animation_tree.active = true
	swordHitbox.knockback_vector = roll_vector


func killed():
	var dead = Dead.instance()
	get_tree().current_scene.get_node("CanvasLayer").add_child(dead)
	stats.reset()
	queue_free()
	

func _physics_process(delta):
	match state:
		
		State.MOVE:
			move_state(delta)
		
		State.ROLL:
			roll_state()
		
		State.ATTACK:
			attack_state()


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta) 
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta) 

	move()
	
	if Input.is_action_just_pressed("attack"):
		state = State.ATTACK
	
	if Input.is_action_just_pressed("roll"):
		state = State.ROLL


func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")


func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animation_state.travel("Roll")
	move()


func move():
	velocity = move_and_slide(velocity)


func attack_animation_finished():
	state = State.MOVE


func roll_animation_finished():
	velocity = velocity / 2
	state = State.MOVE


func _on_HurtBox_area_entered(area):
	if !hurtbox.invincible:
		stats.health -= area.Damage
		hurtbox.start_invincibility(INVINCIBLE)
		hurtbox.create_hit_effect()
		var player_hurt_sound = PlayerHurtSound.instance()
		get_tree().current_scene.add_child(player_hurt_sound)


func add_health(lives):
	stats.max_health += lives


func _on_HurtBox_invincibility_started():
	blink_animation_player.play("Start")


func _on_HurtBox_invincibility_finished():
	blink_animation_player.play("Stop")
