extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500

enum State {
	MOVE,
	ROLL,
	ATTACK,
}

var state = State.MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitBox

func _ready():
	animation_tree.active = true
	swordHitbox.knockback_vector = roll_vector


func _physics_process(delta):
	match state:
		
		State.MOVE:
			move_state(delta)
		
		State.ROLL:
			roll_state(delta)
		
		State.ATTACK:
			attack_state(delta)


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


func attack_state(_delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")


func roll_state(_delta):
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
