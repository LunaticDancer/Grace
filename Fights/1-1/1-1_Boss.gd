extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var game_controller = get_tree().get_first_node_in_group("game_controller")

@export var movement_speed = 20.0
@export var turn_rate = 3.0

@export var attack_pattern_odds_bag : Array[String]
@export var bullet1 : PackedScene

var movement_direction = Vector2.DOWN

# Called when the node enters the scene tree for the first time.
func _ready():
	game_controller.boss_killed.connect(die)
	start_next_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	recalculate_movement_direction(delta)
	global_position = global_position + movement_direction * movement_speed * delta

func start_next_attack():
	$AnimationPlayer.stop()
	$AnimationPlayer.play(attack_pattern_odds_bag.pick_random())

func star_attack_straight():
	var num = 13
	for i in num:
		var bullet = bullet1.instantiate()
		bullet.global_position = global_position
		bullet.init( Vector2(cos((2 * PI) / num * i), sin((2 * PI) / num * i)) )
		get_parent().add_child(bullet)

func star_attack_opposite():
	var num = 13
	for i in num:
		var bullet = bullet1.instantiate()
		bullet.global_position = global_position
		bullet.init( Vector2(cos((2 * PI) / num * i + PI/num), sin((2 * PI) / num * i + PI/num)) )
		get_parent().add_child(bullet)

func recalculate_movement_direction(delta):
	if player == null:
		return
	movement_direction = (movement_direction + (delta * turn_rate * 
		global_position.direction_to(player.global_position))).normalized()

func die():
	game_controller.boss_killed.disconnect(die)
	queue_free()
