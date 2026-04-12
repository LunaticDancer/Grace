extends Area2D

@export var manual_speed : float = 500
var screenResolution : Vector2
var game_controller

func initialize(p_position : Vector2, p_game_controller):
	body_entered.connect(on_body_entered)
	area_entered.connect(on_area_entered)
	game_controller = p_game_controller
	position = p_position
	screenResolution = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))

func _process(delta: float) -> void:
	var movement = Input.get_vector("left", "right", "up", "down")
	handle_player_movement(movement * (manual_speed * .4 if Input.is_action_pressed("focus")
		else manual_speed) * delta)

func _input(event):
	if event is InputEventScreenDrag:
		handle_player_movement(event.relative)

func on_body_entered(area):
	if area.is_in_group("kills_player"):
		die()

func on_area_entered(area):
	if area.is_in_group("kills_player"):
		die()

func die():
	if game_controller.boss_hp <= 0:
		return
	body_entered.disconnect(on_body_entered)
	area_entered.disconnect(on_area_entered)
	game_controller.game_over()
	queue_free()

func handle_player_movement(position_delta:Vector2):
	var target_position = position + position_delta
	target_position = Vector2(clamp(target_position.x, 0, screenResolution.x), 
		clamp(target_position.y, 0, screenResolution.y))
	position = target_position
