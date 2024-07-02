extends Node2D

@export var far_end = 200
@export var near_end = 20
@export var max_grace_value = 20

@onready var player = get_tree().get_first_node_in_group("player")
@onready var game_controller = get_tree().get_first_node_in_group("game_controller")

func _ready():
	set_process_priority(1000)

func _process(delta):
	if (player == null || game_controller == null):
		return
	
	var distance = global_position.distance_to(player.global_position)
	if distance > far_end:
		return
	game_controller.add_cummulative_grace(clamp(inverse_lerp(far_end, near_end, 
		distance), 0, 1) * max_grace_value)
