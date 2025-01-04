extends Node

onready var _Player = get_tree().current_scene.get_node_or_null("Viewport/main/entities/player")
onready var _PlayerData = get_node("/root/PlayerData")
onready var _Globals = get_node("/root/Globals")

func _ready():
	pass
