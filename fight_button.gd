extends TextureButton

@export var fight_data : Resource

func _pressed():
	get_node("/root/GameController").init_level(fight_data)
