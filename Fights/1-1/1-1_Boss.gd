extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var game_controller = get_tree().get_first_node_in_group("game_controller")

@export var lurch_speed : Vector2
@export var lurch_threshold : float
@export var speed_decay_per_second : Vector2
@export var movement_speed = 20.0
@export var turn_rate = 3.0
var movement_direction = Vector2.DOWN

@export var attack_pattern_odds_bag : Array[String]
var bullet1 : PackedScene = load("res://Fights/1-1/bullet_1.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	game_controller.boss_killed.connect(die)
	start_next_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_movement(delta)

func handle_movement(delta):
	if movement_speed < lurch_threshold * lerp(lurch_speed.x, lurch_speed.y, game_controller.current_grace/100):
		lurch(delta)
	global_position = global_position + movement_direction * movement_speed * delta
	movement_speed -= lerp(speed_decay_per_second.x, speed_decay_per_second.y, game_controller.current_grace/100) * delta
	if player != null:
		movement_direction = (movement_direction + (delta * turn_rate * 
			global_position.direction_to(player.global_position))).normalized()

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

func lurch(delta):
	if player == null:
		return
	movement_direction = (movement_direction + 
		2 * global_position.direction_to(player.global_position)).normalized()
	movement_speed = lerp(lurch_speed.x, lurch_speed.y, game_controller.current_grace/100)
	#movement_direction = (movement_direction + (delta * turn_rate * 
	#	global_position.direction_to(player.global_position))).normalized()

func die():
	game_controller.boss_killed.disconnect(die)
	queue_free()
