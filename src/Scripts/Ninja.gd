extends KinematicBody2D

const FLOOR =  Vector2(0, -1)
const SPEED_LIMIT = 300
const GRAVITY = 10
const JUMP_LIMIT = -400


var velocity = Vector2()
var on_ground = false
var curr_speed = 0
var curr_jump = -200
var accel = 2
var last_side = 0
var attacking = false
var curr_anim = ""
var jump_count = 2
var on_wall = false
var atrito = -5

func _ready():
	$Timer.connect("timeout", self, "atk_off")
	
func _physics_process(delta):
	
#	if not attacking:
#		get_input(delta)
	jump()
	if on_ground:
		direction()

	$Sprite.play(curr_anim)
	
	if not on_wall:
		velocity.y += GRAVITY
	else: 
		velocity.y += GRAVITY + atrito
		
	velocity = move_and_slide(velocity, FLOOR)


func atk_off():
	attacking = false
		
func aceleration(var side):
	if side != 0:
		if abs(curr_speed) < SPEED_LIMIT:
			curr_speed += accel * side
	else:
#		-------------------BREAKING-----------------
		if abs(curr_speed) > 25:
			curr_speed /= 1.07

		elif abs(curr_speed) <= 25:
			curr_speed = 0
			
	if abs(curr_speed) > 180:
		curr_anim = "running"
	else:
		curr_anim = "walking"
	
	if abs(curr_speed) > SPEED_LIMIT:
		curr_speed = SPEED_LIMIT * side

	return curr_speed
	##################################### INPUT MANAGEMENT ########################

func attack():
	if Input.is_action_pressed("atk1"):
		attacking = true
		curr_anim = "atk1"
		$Timer.set_wait_time(0.45)
		$Timer.start()
		
func jump():
	if is_on_floor():
		on_ground = true
		jump_count = 2
	else:
		on_ground = false
		if velocity.y < 0:
			curr_anim = "jumping"
		else:
			curr_anim = "falling"
		
		if on_wall:
			curr_anim = "wall"
			
	if Input.is_action_pressed("ui_up"):
		if curr_jump > JUMP_LIMIT and on_ground:
			curr_jump -= 4
	
	elif Input.is_action_just_released("ui_up") and jump_count > 0:
			jump_count -= 1
			if on_wall:
				curr_speed = 150 * last_side
				velocity.x = curr_speed 
			velocity.y = curr_jump
			on_ground = false
			
			curr_jump = -200
	
func direction():
	if Input.is_action_pressed("ui_right") and last_side != -1:
		$Sprite.flip_h = false
		if try_move(Vector2(1,-1)):
			velocity.x = aceleration(1)
#			curr_anim = running")
			last_side = 1
		else:
			curr_anim = "idle"
			
	elif Input.is_action_pressed("ui_left") and last_side != 1:
		$Sprite.flip_h = true
		if try_move(Vector2(-1,-1)) :
			velocity.x = aceleration(-1)
#			curr_anim = "running"
			last_side = -1
		else:
			curr_anim = "idle"
		
	else:
#		#------------IDLE-------------
		try_move(Vector2(-1,-1))
		if last_side != 0:
			curr_anim = "stopping"

		velocity.x = aceleration(0)
		
		if curr_speed == 0:
			curr_anim = "idle"
			last_side = 0

func try_move(rel_vec):
	if test_move(transform,rel_vec):
		curr_speed = 0
		return false
	else:
		return true

func _on_Area2D_body_entered(body):
	if body.name == "Enviroment" and not on_ground:
		on_wall = true
		curr_speed = 0
		print(velocity.y)
		
		if $Sprite.is_flipped_h():
			 last_side = 1
		else:
			last_side = -1
			
		$Sprite.flip_h = not $Sprite.is_flipped_h()
		jump_count = 2

func _on_Area2D_body_exited(body):
	if body.name == "Enviroment":
		on_wall = false
