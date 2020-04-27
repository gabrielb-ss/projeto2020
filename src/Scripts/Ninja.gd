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
var grab = false
var last_scale = 0

func _ready():
	$Timer.connect("timeout", self, "atk_off")
	
func _physics_process(delta):
	
	jump()
	if on_ground:
		direction()
		
	$Sprite.play(curr_anim)
	
	if not grab:
		velocity.y += GRAVITY
	else: 
		velocity.y += 0.25
		
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
			
	if Input.is_action_pressed("ui_up") and curr_jump > JUMP_LIMIT and (on_ground or on_wall):
		curr_jump -= 4
	
	elif Input.is_action_just_released("ui_up") and jump_count > 0:
			scale_direction(last_side)
			jump_count -= 1
			if on_wall:
				curr_speed = 150 * last_side
				velocity.x = curr_speed 
			velocity.y = curr_jump
			on_ground = false
			
			curr_jump = -200
	
	if Input.is_action_just_pressed("grab") and on_wall and not on_ground: 
		velocity.y = 0
		grab = not grab
		
		if grab:
			jump_count = 2
			if $Sprite.is_flipped_h():
				 last_side = 1
			else:
				last_side = -1
		else:
			last_side = 0

		$Sprite.flip_h = not $Sprite.is_flipped_h()
		
func direction():
	if Input.is_action_pressed("ui_right") and last_side != -1:
		last_side = 1
		if last_scale != last_side:
			scale_direction(last_side)
		
		if try_move(Vector2(1,-1)):
			velocity.x = aceleration(1)
			
	elif Input.is_action_pressed("ui_left") and last_side != 1:
		last_side = -1
		if last_scale != last_side:
			scale_direction(last_side)

		if try_move(Vector2(-1,-1)) :
			velocity.x = aceleration(-1)
			
	else:
		velocity.x = aceleration(0)
		
		if curr_speed == 0:
			curr_anim = "idle"
			last_side = 0

func try_move(rel_vec):
	if test_move(transform,rel_vec):
		velocity.x = 0
		curr_anim = "idle"
		return false
	else:
		return true

func _on_Area2D_body_entered(body):
	if body.name == "Enviroment":
		on_wall = true
		curr_speed = 0
		jump_count = 1

func _on_Area2D_body_exited(body):
	if body.name == "Enviroment":
		on_wall = false
		grab = false

func scale_direction(var side):
	print("SCALE")
	if side != 0:
		if side == 1:
			$Sprite.flip_h = false
		else:
			$Sprite.flip_h = true
			
		$HitBox.set_scale(Vector2(side,1))
	
	last_scale = side
