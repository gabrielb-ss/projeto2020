extends KinematicBody2D

const GRAVITY = 10
const FLOOR =  Vector2(0, -1)
var velocity = Vector2()
var speed = 150
onready var obj = get_parent().get_node("Ninja")

func _physics_process(delta):
	var dir = (obj.global_position - global_position).normalized()
	velocity.x = dir.x * speed
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
