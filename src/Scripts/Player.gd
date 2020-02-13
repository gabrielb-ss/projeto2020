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

func _physics_process(delta):
	get_input(delta)
	$TurnAxis.rotation = get_angle_to(get_global_mouse_position())
	velocity = move_and_slide(velocity, FLOOR)
	velocity.y += GRAVITY

func get_input(delta):
	if Input.is_action_pressed("ui_right"):
		$TurnAxis.set_position(Vector2(10,-5))
		$Sprite.flip_h = false
		if try_move(Vector2(1,-1)):
			velocity.x = SPEED
			$Sprite.play("running")
		else:
			$Sprite.play("iddle")
			
	elif Input.is_action_pressed("ui_left"):
		$TurnAxis.set_position(Vector2(-5,-5))
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
	if Input.is_action_pressed("Shoot") and can_fire == true:
		shoot(delta)
		
func shoot(delta):
	can_fire = false
	drag_dist = $TurnAxis.get_global_position().x - get_global_mouse_position().x
	
	if  drag_dist > 3 and drag_dist < 180 and $Sprite.is_flipped_h() == false:
		create_arrow(delta)
		
	elif drag_dist < -3 and drag_dist > -180 and $Sprite.is_flipped_h() == true: 
		create_arrow(delta)
		
	yield(get_tree().create_timer(rate_of_fire), "timeout")
	can_fire = true
	
func create_arrow(delta):
	var arrow_inst = arrow.instance()
	arrow_inst.position = $TurnAxis.get_global_position()
	arrow_inst.rotation = position.angle_to_point(get_global_mouse_position())
	get_parent().add_child(arrow_inst)
	
	var rigidbody_vector = (self.get_position() - get_global_mouse_position()).normalized()
	var mouse_distance = self.get_position().distance_to(get_global_mouse_position())
	arrow_inst.set_linear_velocity(rigidbody_vector * 200 * mouse_distance * delta)
	
func try_move(rel_vec):
	if test_move(transform,rel_vec):
		return false
	else:
		 return true
		
#	velocity = velocity.normalized()


