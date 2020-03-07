extends KinematicBody2D

var turn = true

func _ready():
	while turn:
		move_and_slide(Vector2(-75, 0))
		$Sprite.play("Idle")
