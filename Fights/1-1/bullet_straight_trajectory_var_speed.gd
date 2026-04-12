extends Area2D

@export var speed = 150
var direction = Vector2.DOWN

func init(p_direction, p_speed):
	direction = p_direction
	speed = p_speed

func _process(delta):
	global_position += speed * delta * direction

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
