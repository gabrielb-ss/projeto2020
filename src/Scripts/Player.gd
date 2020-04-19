extends KinematicBody2D

const SPEED_LIMIT = 200
const GRAVITY = 10
const JUMP = -200
const FLOOR =  Vector2(0, -1)
var arrow = preload("res://src/Scenes/Arrow.tscn")
var arrow_count = 5
var can_fire = true
var rate_of_fire = 0.4
var velocity = Vector2()
var on_ground = false
var hold = 100
var count = false
var last_side = 0
var hurt = false
var curr_speed = 0
var acel = 4
var breaking = false

func _physics_process(delta):
	if $Camera2D/Hp.get_value() <= 0:
#		queue_free()
		self.hide()
			
	get_input(delta)
	$Bow.rotation = get_angle_to(get_global_mouse_position())
	velocity.x= curr_speed
	print(velocity.x)
	
	velocity = move_and_slide(velocity, FLOOR)
	velocity.y += GRAVITY

func aceleration(var side, var flag):
	
	if flag == 0:
		if abs(curr_speed) > SPEED_LIMIT:
			curr_speed = SPEED_LIMIT 
		else:
			curr_speed += (acel * side)
	else:
		if abs(curr_speed) > 0:
			curr_speed -= (acel * last_side)
			
	return curr_speed 
		
func get_input(delta):
	
	if Input.is_action_pressed("ui_right") and on_ground and not breaking:
		$Sprite.flip_h = false
		if try_move(Vector2(1,-1)) :
			aceleration(1, 0)
			$Sprite.play("running")
			last_side = 1
		else:
			$Sprite.play("iddle")
			
	elif Input.is_action_pressed("ui_left") and on_ground and not breaking:
		$Sprite.flip_h = true
		if try_move(Vector2(-1,-1)):
			aceleration(-1, 0)
			$Sprite.play("running")
			last_side = -1
		else:
			$Sprite.play("iddle")
	else:
#------------IDLE-------------
		aceleration(0,1)
		if on_ground == true and curr_speed == 0:
			$Sprite.play("iddle")
	
	if Input.is_action_pressed("ui_up"):
		if on_ground == true:
			velocity.y = JUMP
			velocity.x += 100
			
			on_ground = false
		
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
		if velocity.y < 0:
			$Sprite.play("jumping")
		else:
			$Sprite.play("falling")
	
#	if Input.is_action_pressed("Raise"):
#		$Bow.set_rotation($Bow.get_rotation()+0.1)
#
#	if Input.is_action_pressed("Decrease"):
#		$Bow.set_rotation($Bow.get_rotation()-0.1)
		
	if Input.is_action_pressed("Shoot") and can_fire == true:
		$Bow.show()
		hold += 8
		if arrow_count > 0:
			$Bow/CastPoint/Light.show()
		count = true
		
	if not Input.is_action_pressed("Shoot") and count:
		count = false
		if hold > 500:
			hold = 500
		if arrow_count > 0:
			$Bow/CastPoint/Light.hide()
			shoot(delta)
			arrow_count -= 1
#			print(arrow_count)
		hold = 100
	
func shoot(delta):
	
	can_fire = false
	
	create_arrow(delta)
		
	yield(get_tree().create_timer(rate_of_fire), "timeout")
	can_fire = true
	$Bow.hide()
	
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

func _on_Area2D_body_entered(body):
	var curr_hp = $Camera2D/Hp.get_value()
	print(body.get_name(), curr_hp)
	if body.get_name() == "Enemy":
		curr_hp -= 10
#		$Sprite/Hurt.show()
		$Camera2D/Hp.set_value(curr_hp)
