extends KinematicBody2D

const SPEED = 200
const GRAVITY = 10
const JUMP = -200
const FLOOR =  Vector2(0, -1)

var velocity = Vector2()
var on_ground = false

func try_move(rel_vec):
	if test_move(transform,rel_vec):
		return false
	else:
		 return true

func get_input():
	if Input.is_action_pressed("ui_right"):
		$Sprite.flip_h = false
		if try_move(Vector2(1,-1)):
			velocity.x = SPEED
			$Sprite.play("running")
		else:
			$Sprite.play("iddle")
			
	elif Input.is_action_pressed("ui_left"):
		$Sprite.flip_h = true
		if try_move(Vector2(-1,-1)):
			velocity.x = -SPEED
			$Sprite.play("running")
		else:
			$Sprite.play("iddle")
	else:
		velocity.x = 0
		if on_ground == true:
			$Sprite.play("iddle")
	
	if Input.is_action_pressed("ui_up"):
		if on_ground == true:
			velocity.y = JUMP
			on_ground = false
			
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
		if velocity.y < 0:
			$Sprite.play("jumping")
		else:
			$Sprite.play("falling")
	
		
#	velocity = velocity.normalized()

func _physics_process(delta):
	get_input()
	velocity = move_and_slide(velocity, FLOOR)
	velocity.y += GRAVITY
	
