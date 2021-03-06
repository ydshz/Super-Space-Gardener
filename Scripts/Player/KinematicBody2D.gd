extends Actor

#Variable declearations
export (float) var speedMultiplier = 1.25
export (float) var crouchMultiplier = 0.75
export (int) var jump = 1100
export (int) var jumpPadHeigh = -2000
var Multiplier = 1
var canUncrouch = false
var state = "idle"
var wallDirection = 1

func _physics_process(delta: float) -> void:
	#Calculates gravity, direction and velocity
	var space_state = get_world_2d().direct_space_state
	var direction: = get_direction()
	#print(Global.isCollidingJumpPad)
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0.0
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	if Global.isCollidingJumpPad:	
		_velocity.y = jumpPadHeigh
		_velocity.x = 0
		move_and_slide(_velocity)
		print(get_position())
		print(Global.isCollidingJumpPad)
		Global.isCollidingJumpPad = false
	
	#State detection
	if Input.get_action_strength("jump") != 0 and state != "wallSlide" and canUncrouch:
		state = "jump"
	if $raycastCrouch.is_colliding() and (state == "crouch" or state == "crouchWalk"):
			canUncrouch = false
	else:
			canUncrouch = true
	if Input.is_action_pressed("sprint") and state == "walk":
		state = "sprint"
	if !Input.is_action_pressed("sprint") and state == "sprint":
		state = "walk"
	if Input.is_action_pressed("ui_left"):
		if state != "crouch" and state != "crouchWalk" and state != "sprint":
			state = "walk"
		elif state != "sprint":
			state = "crouchWalk"
		get_node( "AnimatedSprite" ).set_flip_h( false )
	elif Input.is_action_pressed("ui_right"):
		if state != "crouch" and state != "crouchWalk" and state != "sprint":
			state = "walk"
		elif state != "sprint":
			state = "crouchWalk"
		get_node( "AnimatedSprite" ).set_flip_h( true )
	elif state != "crouch" and state != "crouchWalking" and state != "sprint" and canUncrouch and state != "jump":
		state = "idle"
	elif state == "crouchWalk":
		state = "crouch"
	if Input.is_action_pressed("crouch") or (!canUncrouch and state == "crouch"):
		if state != "crouchWalk":
			state = "crouch"
	elif canUncrouch and state != "walk" and state != "sprint" and state != "jump":
		state = "idle"
	if wallDirection != 0 :
		state = "wallSlide"
	elif state == "wallSlide" && wallDirection == 0:
		state = "idle"
	if state == "jump" and is_on_floor():
		state = "default"
		
	#State execution
	if state == "crouch":
		$defaultHitbox.disabled = true
		$crouchHitbox.disabled = false
		$AnimatedSprite.animation = "crouch"
		Multiplier = crouchMultiplier
	elif state == "idle":
		$defaultHitbox.disabled = false
		$crouchHitbox.disabled = true
		$AnimatedSprite.animation = "default"
		Multiplier = 1
	elif state == "walk":
		$defaultHitbox.disabled = false
		$crouchHitbox.disabled = true
		$AnimatedSprite.animation = "walk"
		Multiplier = 1
	elif state == "crouchWalk":
		$defaultHitbox.disabled = true
		$crouchHitbox.disabled = false
		$AnimatedSprite.animation = "crouchWalk"
		Multiplier = crouchMultiplier
	elif state == "sprint":
		$defaultHitbox.disabled = false
		$crouchHitbox.disabled = true
		$AnimatedSprite.animation = "walk"
		Multiplier = speedMultiplier
	elif state == "jump":
		$defaultHitbox.disabled = false
		$crouchHitbox.disabled = true
		$AnimatedSprite.animation = "jumpAnimation"
		Multiplier = 1
	elif state == "wallSlide":
		$defaultHitbox.disabled = false
		$crouchHitbox.disabled = true
		$AnimatedSprite.animation = "wallslide"
		Multiplier = 3
	
	#Moves the Player
	var snap: Vector2 = Vector2.DOWN * 60.0 if direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity , snap, FLOOR_NORMAL, true
	)
	print(_velocity)
	#Resets the jumpPad collision and updates the wallDirection
	updateWallDirection()

#Calculates the direction as a Vector2
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		-Input.get_action_strength("jump") if (is_on_floor() or state == "wallSlide") and Input.is_action_just_pressed("jump") else 0.0
	)

#Calculates the move_velocity out of the linear_velocity, direction and speed
func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	speed.x *= Multiplier
	var velocity: = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	return velocity


func checkWall(raycast):
	if raycast.is_colliding() and !is_on_floor():
		return true
	else:
		return false

func updateWallDirection():
	var isNearWallLeft = checkWall($leftCollision)
	var isNearWallRight = checkWall($rightCollision)
	if isNearWallLeft && isNearWallRight:
		wallDirection = 0
	else:
		wallDirection = -int(isNearWallLeft) + int(isNearWallRight)
