extends Area2D

@export var speed = 150
@export var speed_decay = 300
@export var launch_speed = 150
var direction = Vector2.DOWN
var launched = false

func init(p_direction):
	direction = p_direction

func _process(delta):
	global_position += speed * delta * direction
	if launched:
		return
	
	speed -= speed_decay * delta
	if speed > 0:
		return
	speed = launch_speed
	launched = true
	if get_tree().get_first_node_in_group("player") == null:
		return
	direction = global_position.direction_to(get_tree().get_first_node_in_group("player").global_position)

func _on_visible_on_screen_notifier_2d_screen_exited():
	if launched:
		queue_free()
