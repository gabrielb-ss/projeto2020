extends RigidBody2D

var speed = 150

func _ready():
	apply_impulse(Vector2(), Vector2(speed, 0).rotated(rotation))
	yield(get_tree().create_timer(3.0), "timeout")
	$Light2D.hide()

func _on_Arrow_body_entered(body):
	if body.get_name() == "Player":
#		print("recuperou")
		$"/root/Node2D/Player".arrow_count += 1
		queue_free()
#	elif body.get_name() == "Arrow":
#		print("Bateu")
