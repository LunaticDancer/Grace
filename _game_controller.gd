extends Control

signal boss_killed

@export var player_scene : PackedScene
@export var damage_per_second = 1.0

var current_fight_data
var boss_hp : float
var boss_max_hp : float

var current_grace : float
var cummulative_grace_this_frame : float

# Called when the node enters the scene tree for the first time.
func _ready():
	show_main_menu()

func _process(delta):
	process_grace(delta)
	deal_damage(delta)

func show_main_menu():
	$MainMenuContainer.show()
	$LevelSelectContainer.hide()
	$GameUiContainer.hide()

func show_level_select_menu():
	$MainMenuContainer.hide()
	$LevelSelectContainer.show()
	$GameUiContainer.hide()

func show_game_ui():
	$MainMenuContainer.hide()
	$LevelSelectContainer.hide()
	$GameUiContainer.show()
	$GameUiContainer/PauseMenu.hide()
	$GameUiContainer/GameOverScreen.hide()
	$GameUiContainer/VictoryScreen.hide()

func show_pause_menu():
	get_tree().paused = true
	$GameUiContainer/PauseMenu.show()

func hide_pause_menu():
	$GameUiContainer/PauseMenu.hide()
	get_tree().paused = false

func game_over():
	$GameUiContainer/GameOverScreen.show()

func init_level(level_data : Resource):
	current_fight_data = level_data
	clear_game_world()
	show_game_ui()
	var player = player_scene.instantiate()
	player.initialize($PlayerSpawnPosition.position, self)
	$GameWorld.add_child(player)
	current_grace = 0
	var boss = level_data.boss_scene.instantiate()
	boss.global_position = $BossSpawnPosition.global_position
	$GameWorld.add_child(boss)
	update_grace_meter()
	init_boss_healthbar(level_data.max_hp)
	$GameUiContainer/BossName.text = level_data.name

func init_boss_healthbar(value : float):
	boss_hp = value
	boss_max_hp = value
	$GameUiContainer/BossHP.max_value = value
	$GameUiContainer/BossHP.value = value

func process_grace(delta):
	if cummulative_grace_this_frame > current_grace:
		current_grace = lerp(current_grace, cummulative_grace_this_frame, 0.5)
	else:
		current_grace -= 20 * delta
	
	current_grace = clamp(current_grace, 0, 100)
	update_grace_meter()
	
	cummulative_grace_this_frame = 0	# make it empty for next frame

func add_cummulative_grace(amount):
	cummulative_grace_this_frame += amount

func update_grace_meter():
	$GameUiContainer/GraceMeter.value = current_grace

func deal_damage(delta):
	if $GameUiContainer/GameOverScreen.visible:
		return
	if boss_hp > 0:
		boss_hp -= current_grace * delta * damage_per_second
		$GameUiContainer/BossHP.value = boss_hp
		if boss_hp <= 0:
			boss_killed.emit()
			$GameUiContainer/VictoryScreen.show()

func clear_game_world():
	for child in $GameWorld.get_children():
		child.queue_free()

func _on_play_button_pressed():
	show_level_select_menu()

func _on_quit_button_pressed():
	get_tree().quit()

func _on_back_to_menu_button_pressed():
	show_main_menu()

func _on_pause_button_pressed():
	show_pause_menu()

func _on_resume_button_pressed():
	hide_pause_menu()

func _on_pause_menu_quit_button_pressed():
	hide_pause_menu()
	show_level_select_menu()
	clear_game_world()

func _on_retry_button_pressed():
	init_level(current_fight_data)
