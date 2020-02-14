extends KinematicBody2D

export (int) var speed = 200
export (int) var speedSprint = 400
export (int) var gravity = 40
export (int) var jump = 6400

var velocity = Vector2()
var up = Vector2(0, -1)

func get_input():
	velocity = Vector2()
	if Input.is_action_just_pressed("crouch"):
		crouch(1)
		print("Crouch")
	if Input.is_action_just_released("crouch"):
		crouch(0)
	if Input.is_action_pressed('ui_right'):
		velocity.x += 1
		get_node( "AnimatedSprite" ).set_flip_h( true )
	if Input.is_action_pressed('ui_left'):
		velocity.x -= 1
		get_node( "AnimatedSprite" ).set_flip_h( false )
	if Input.is_action_pressed('sprint'):
		velocity = velocity.normalized() * speedSprint
	else:
		velocity = velocity.normalized() * speed
		

func _physics_process(_delta):
	get_input()
	
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = -jump
	if !is_on_floor() or is_on_ceiling():
		velocity.y += gravity
	velocity = move_and_slide(velocity, up)

func crouch(state):
	if state:
		$defaultHitbox.disabled = true
		$crouchHitbox.disabled = false
		$AnimatedSprite.animation = "crouch"
		print("Crouch")
	else:
		$defaultHitbox.disabled = false
		$crouchHitbox.disabled = true
		$AnimatedSprite.animation = "default"
		print("uncrouch")
