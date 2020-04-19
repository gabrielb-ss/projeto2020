extends KinematicBody2D

const FLOOR =  Vector2(0, -1)
const SPEED_LIMIT = 300
const GRAVITY = 10
const JUMP = -200

var velocity = Vector2()
var on_ground = false
var curr_speed = 0
var accel = 2
var last_side = 0

func _physics_process(delta):
	
	get_input(delta)
	
	velocity = move_and_slide(velocity, FLOOR)
	velocity.y += GRAVITY

func aceleration(var side):
	if side != 0:
		if abs(curr_speed) < SPEED_LIMIT:
			curr_speed += accel * side
	else: 
#		-------------------BREAKING-----------------
		if abs(curr_speed) > 25 and on_ground:
			curr_speed /= 1.07
#
#			if curr_speed < 0:
#				curr_speed = 0
				
		elif abs(curr_speed) <= 25 and on_ground:
			curr_speed = 0
			
	if abs(curr_speed) > 200:
		$Sprite.play("running")
	else:
		$Sprite.play("walking")	
	
	if abs(curr_speed) > SPEED_LIMIT:
		curr_speed = SPEED_LIMIT * side
	print(curr_speed)
	
	return curr_speed
	
	##################################### INPUT MANAGEMENT ########################
			
func get_input(delta):
	
	if Input.is_action_pressed("ui_right") and on_ground  and last_side != -1:
		$Sprite.flip_h = false
		if try_move(Vector2(1,-1)):
			velocity.x = aceleration(1)
#			$Sprite.play("running")
			last_side = 1
		else:
			$Sprite.play("idle")
			
	elif Input.is_action_pressed("ui_left") and on_ground and last_side != 1:
		$Sprite.flip_h = true
		if try_move(Vector2(-1,-1)) :
			velocity.x = aceleration(-1)
#			$Sprite.play("running")
			last_side = -1
		else:
			$Sprite.play("idle")
	else:
#		#------------IDLE-------------
		try_move(Vector2(-1,-1))
		if last_side != 0:
			$Sprite.play("stopping")

		velocity.x = aceleration(0)
		
		if on_ground and curr_speed == 0:
			$Sprite.play("idle")
			last_side = 0
	
	if Input.is_action_pressed("ui_up"):
		if on_ground:
			velocity.y = JUMP
#			velocity.x += 100
			
			on_ground = false
			
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
		if velocity.y < 0:
			$Sprite.play("jumping")
		else:
			$Sprite.play("falling")

func try_move(rel_vec):
	if test_move(transform,rel_vec):
		curr_speed = 0
		return false
	else:
		 return true

