extends Area2D

@export var lerp_speed = 0.1
var player

func init(p_player):
	player = p_player

func _process(delta):
	if player == null:
		return
	global_position = lerp(global_position, player.global_position, lerp_speed)

