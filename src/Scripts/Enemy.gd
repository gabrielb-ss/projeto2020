extends KinematicBody2D

var turn = true
var velocity = Vector2(-75,0)

func _physics_process(delta):
	move_and_slide(velocity)
	$Sprite.play("Walk")
	
	
func _on_Area2D_body_entered(body):
	if body.get_name() == "Enviroment":
		apply_scale(Vector2(-1,1))
		if velocity.x < 0:
			velocity.x = -75
		else:
			velocity.x = 75
			
		velocity.x *= -1
	elif body.get_name() == "Player":
		velocity *= 2
