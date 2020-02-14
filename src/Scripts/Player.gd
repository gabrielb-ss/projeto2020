extends KinematicBody2D

const SPEED = 130
const GRAVITY = 10
const JUMP = -200
const FLOOR =  Vector2(0, -1)
var arrow = preload("res://src/Scenes/Arrow.tscn")
var can_fire = true
var rate_of_fire = 0.4
var drag_dist = 0
var velocity = Vector2()
var on_ground = false
var hold = 100
var count = false
var turn = false

func _physics_process(delta):
	get_input(delta)
#	$Bow.rotation = get_angle_to(get_global_mouse_position())
	velocity = move_and_slide(velocity, FLOOR)
	velocity.y += GRAVITY

func get_input(delta):
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
	
	if Input.is_action_pressed("Raise"):
		$Bow.set_rotation($Bow.get_rotation()+0.1)
		
	if Input.is_action_pressed("Decrease"):
		$Bow.set_rotation($Bow.get_rotation()-0.1)
		
	if Input.is_action_pressed("Shoot") and can_fire == true:
		hold += 8
		count = true
		
	if not Input.is_action_pressed("Shoot") and count:
		count = false
		if hold > 500:
			hold = 500
		shoot(delta)
		hold = 100
	
	
func shoot(delta):
	print(hold)
	can_fire = false
	
	create_arrow(delta)
		
	yield(get_tree().create_timer(rate_of_fire), "timeout")
	can_fire = true
	
func create_arrow(delta):
	var arrow_inst = arrow.instance()
	arrow_inst.position = $Bow/CastPoint.get_global_position()
	arrow_inst.rotation = $Bow.get_rotation()
	arrow_inst.speed += hold
	get_parent().add_child(arrow_inst)
	
func try_move(rel_vec):
	if test_move(transform,rel_vec):
		return false
	else:
		 return true
		
#	velocity = velocity.normalized()


