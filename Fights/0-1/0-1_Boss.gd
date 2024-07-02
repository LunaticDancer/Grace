extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var game_controller = get_tree().get_first_node_in_group("game_controller")

@export var movement_speed = 20.0
@export var turn_rate = 3.0

@export var attack_pattern_odds_bag : Array[String]
@export var bullet1 : PackedScene
@export var bullet2 : PackedScene
var chasing_bullet_instance

var movement_direction = Vector2.DOWN

# Called when the node enters the scene tree for the first time.
func _ready():
	game_controller.boss_killed.connect(die)
	$AnimationPlayer.play("phase_1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_phase_transitions()

func handle_phase_transitions():
	if $AnimationPlayer.current_animation == "phase_1":
		if (game_controller.boss_hp / game_controller.boss_max_hp) < 0.85:
			$AnimationPlayer.play("phase_2_start")
	if $AnimationPlayer.current_animation == "phase_2":
		if (game_controller.boss_hp / game_controller.boss_max_hp) < 0.45:
			$AnimationPlayer.play("phase_3_start")
			chasing_bullet_instance.queue_free()

func power_word_gunfire():
	if player == null:
		return
	var bullet = bullet1.instantiate()
	bullet.global_position = global_position
	bullet.init( global_position.direction_to(player.global_position) )
	get_parent().add_child(bullet)

func spawn_the_chaser():
	if player == null:
		return
	chasing_bullet_instance = bullet2.instantiate()
	chasing_bullet_instance.global_position = global_position
	chasing_bullet_instance.init(player)
	get_parent().add_child(chasing_bullet_instance)

func die():
	game_controller.boss_killed.disconnect(die)
	queue_free()
