extends Resource

@export var name: String
@export var max_hp: float
@export var boss_scene: PackedScene

func _init(p_name = "Maurice", p_max_hp = 1000, p_boss_scene = null):
	name = p_name
	max_hp = p_max_hp
	boss_scene = p_boss_scene
