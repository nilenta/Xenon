extends Node

var _funcs = load("res://mods/Nilenta.Xenon/Components/Functions.gd").new()

func get_player_node():
	return get_tree().current_scene.get_node_or_null("Viewport/main/entities/player")

func _ready():
	var player = get_player_node()
	if player:
		print("PLAYER FOUND")
		player.player_scale = 3
	else:
		print("No player")
