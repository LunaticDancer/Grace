extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var game_controller = get_tree().get_first_node_in_group("game_controller")

@export var lurch_speed : Vector2
@export var lurch_threshold : float
@export var speed_decay_per_second : Vector2
@export var movement_speed = 20.0
@export var turn_rate = 3.0
var movement_direction = Vector2.DOWN

var sideways_bullet : PackedScene = load("res://Fights/1-1/side_bullet.tscn")
@export var sideways_bullet_interval : Vector2
var sideways_bullet_timer : float = 2

@export var attack_pattern_odds_bag : Array[String]
var bullet1 : PackedScene = load("res://Fights/1-1/bullet_1.tscn")
var spread_bullet : PackedScene = load("res://Fights/1-1/spread_attack_bullet.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	game_controller.boss_killed.connect(die)
	start_next_attack()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_movement(delta)
	handle_sideways_bullets(delta)

func handle_sideways_bullets(delta):
	if player == null:
		return
	sideways_bullet_timer -= delta
	if sideways_bullet_timer < 0:
		sideways_bullet_timer += lerp(sideways_bullet_interval.x, sideways_bullet_interval.y, game_controller.current_grace/100)
		var dir_to_player = global_position.direction_to(player.global_position)
		var bullet = sideways_bullet.instantiate()
		bullet.global_position = global_position + Vector2(dir_to_player.y, -dir_to_player.x) * 100
		bullet.init( Vector2(dir_to_player.y, -dir_to_player.x) )
		add_sibling(bullet)
		bullet = sideways_bullet.instantiate()
		bullet.global_position = global_position + Vector2(-dir_to_player.y, dir_to_player.x) * 100
		bullet.init( Vector2(-dir_to_player.y, dir_to_player.x) )
		add_sibling(bullet)

func handle_movement(delta):
	if movement_speed < lurch_threshold * lerp(lurch_speed.x, lurch_speed.y, game_controller.current_grace/100):
		lurch()
	global_position = global_position + movement_direction * movement_speed * delta
	movement_speed -= lerp(speed_decay_per_second.x, speed_decay_per_second.y, game_controller.current_grace/100) * delta
	if player != null:
		movement_direction = (movement_direction + (delta * turn_rate * 
			global_position.direction_to(player.global_position))).normalized()

func start_next_attack():
	$AnimationPlayer.stop()
	$AnimationPlayer.play(attack_pattern_odds_bag.pick_random())

func multispeed_three_spread_attack():
	if player == null:
		return
	var dir_to_player = global_position.direction_to(player.global_position)
	for i in range(1,3 + int(game_controller.current_grace/20)):
		var bullet = spread_bullet.instantiate()
		bullet.global_position = global_position
		bullet.init( dir_to_player, 100 * i)
		add_sibling(bullet)
		bullet = spread_bullet.instantiate()
		bullet.global_position = global_position
		bullet.init( Vector2.from_angle(dir_to_player.angle() + PI/4), 100 * i)
		add_sibling(bullet)
		bullet = spread_bullet.instantiate()
		bullet.global_position = global_position
		bullet.init( Vector2.from_angle(dir_to_player.angle() - PI/4), 100 * i)
		add_sibling(bullet)

func star_attack_straight():
	return
	var num = 13
	for i in num:
		var bullet = bullet1.instantiate()
		bullet.global_position = global_position
		bullet.init( Vector2(cos((2 * PI) / num * i), sin((2 * PI) / num * i)) )
		add_sibling(bullet)

func star_attack_opposite():
	return
	var num = 13
	for i in num:
		var bullet = bullet1.instantiate()
		bullet.global_position = global_position
		bullet.init( Vector2(cos((2 * PI) / num * i + PI/num), sin((2 * PI) / num * i + PI/num)) )
		add_sibling(bullet)

func lurch():
	if player == null:
		return
	movement_direction = (movement_direction + 
		2 * global_position.direction_to(player.global_position)).normalized()
	movement_speed = lerp(lurch_speed.x, lurch_speed.y, game_controller.current_grace/100)

func die():
	game_controller.boss_killed.disconnect(die)
	queue_free()
