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
var curr_anim = ""
var jump_count = 2
var on_wall = false
var grabbing = false
var last_scale = 0
var hurting = false
var delta_count = 60
var dead = false

#func _ready():
#	$Stats/JumpBar.value = 200
#
func jump_orbs():
	if jump_count <= 0:
		$Stats/Orb.hide()
		$Stats/Orb1.hide()
	elif jump_count == 1:
		$Stats/Orb.show()
		$Stats/Orb1.hide()
	elif jump_count >= 2:
		$Stats/Orb.show()
		$Stats/Orb1.show()
	
func _physics_process(delta):
	if not dead:
		jump()
		if on_ground:
			direction()
			
		if hurting:
			damage_taken()
		else:
			$Sprite.play(curr_anim)
		
		if not grabbing:
			velocity.y += GRAVITY
		else: 
			velocity.y += 0.20
		
		velocity = move_and_slide(velocity, FLOOR)

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

func scale_direction(var side):
	if side != 0:
		if side == 1:
			$Sprite.flip_h = false
		else:
			$Sprite.flip_h = true
			
		$Shape.set_scale(Vector2(side,1))
		last_scale = side

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

func jump():
	jump_orbs()
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
			
	if Input.is_action_pressed("ui_up") and curr_jump > JUMP_LIMIT and (on_ground or on_wall) and jump_count > 0:
		curr_jump -= 4
		$Stats/JumpBar.value += 4
	
	elif Input.is_action_just_released("ui_up") and jump_count > 0:
#			scale_direction(last_side)
			$Stats/JumpBar.value = 200
			if on_wall:
				wall_jump()
				
			jump_count -= 1
			velocity.y = curr_jump
			on_ground = false
			
			curr_jump = -200
	
	if Input.is_action_just_pressed("grab") and on_wall and not on_ground: 
		grab()
		
		
func wall_jump():
	if grabbing:
		grab()
	if Input.is_action_pressed("ui_right") and last_scale == -1 or Input.is_action_pressed("ui_left") and last_scale == 1:
		last_scale *= -1
		curr_speed = 150 * last_scale
		scale_direction(last_scale)
		last_side = last_scale
		
	velocity.x = curr_speed 
		
func grab():
	jump_count = 1
	velocity.y = 0
	grabbing = not grabbing
	
	$Sprite.flip_h = not $Sprite.is_flipped_h()
		
func _on_GrabArea_body_entered(body):
	if body.name == "Enviroment":
		on_wall = true
		curr_speed = 0
#		if jump_count == 0 and not grabbing:
		jump_count = 1

func _on_GrabArea_body_exited(body):
	if body.name == "Enviroment":
		on_wall = false
		grabbing = false

func damage_taken():
	if delta_count <= 0:
		$Stats/Hp.value -= 10
		delta_count = 60
	else:
		delta_count -= 1
		
	if $Stats/Hp.value > 0:
		$Sprite.play("hurting")
	else: 
		dead = true
		$Sprite.play("diying")
		yield(get_tree().create_timer(1.2), "timeout")
		queue_free()

func _on_Hurtbox_body_entered(body):
	if body.name.find("Enemy", 0) != -1:
		$Stats/Hp.value -= 10
		delta_count = 60
		hurting = true
	
func _on_Hurtbox_body_exited(body):
	if body.name.find("Enemy", 0) != -1:
		hurting = false
