extends KinematicBody2D

const GRAVITY = 10
const FLOOR =  Vector2(0, -1)
var velocity = Vector2()
var speed = 150
onready var obj = get_parent().get_node("Ninja")
var dir

func _physics_process(delta):
	if str(obj) != "[Deleted Object]":
		dir = (obj.global_position - global_position).normalized()
	if dir.x > 0:
		$Sprite.flip_h = true
		$HurtBox.set_scale(Vector2(-1,1))
	else:
		$Sprite.flip_h = false
		$HurtBox.set_scale(Vector2(1,1))
		
	velocity.x = dir.x * speed
	if abs(velocity.x) > 10:
		$Sprite.play("walk")
	else:
		$Sprite.play("idle")
		
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	
func _on_HitBox_body_entered(body):
	if body.name == "Player":
		$Sprite.play("attack")
