extends KinematicBody2D

const FLOOR =  Vector2(0, -1)
const GRAVITY = 10
var speed = -100
var velocity = Vector2(-75,0)
var on_ground = false


func _physics_process(delta):
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
	
	velocity = move_and_slide(velocity, FLOOR)
	velocity.y += GRAVITY
	velocity.x = speed
#	if u_turn():
		
	$Sprite.play("Walk")
	
	
func _on_Area2D_body_entered(body):
	if body.get_name() == "Enviroment":
		apply_scale(Vector2(-1,1))
		speed *= -1
	elif body.get_name() == "Player":
		velocity.x *= 2
