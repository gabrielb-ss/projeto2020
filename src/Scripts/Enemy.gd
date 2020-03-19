extends KinematicBody2D

const FLOOR =  Vector2(0, -1)
const GRAVITY = 10
var speed = -100
var velocity = Vector2(-75,0)
var on_ground = false
var hp = 200


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
	var name = " " 
	name = body.get_name()
	if  name == "Enviroment":
		apply_scale(Vector2(-1,1))
		speed *= -1
	elif name == "Player":
		velocity.x *= 2
	elif name.find("Arrow", 0) != -1:
		var currhp = $Hp.get_value()
		currhp -= 25
		$Hp.set_value(currhp)
		
		if currhp <= 0:
			queue_free()
