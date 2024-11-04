extends Node
class_name Hooks

var _Player: Node
var _PlayerData: Node
var _options = {
	"Message": "",
	"SpawnAmount": 1,
	"SpawnType": "player",
	"SpawnOffsetX": 0,
	"SpawnOffsetY": 0,
	"SpawnOffsetZ": 0,
	"SpawnSteamId": 0
}

func setup(Player: Node, PlayerData: Node) -> void:
	_Player = Player
	_PlayerData = PlayerData
	#_PlayerData.connect("_chalk_draw", self, "_on_chalk_draw")

func _set_option(key: String, value) -> void:
	if key in _options:
		print("[XENON_GD]: Changing ", key, " to ", str(value), " in Hooks.gd")
		_options[key] = value
		
func _get_options() -> Dictionary:
	return _options

func _set_player(Player: Node) -> void:
	_Player = Player

func get_player_node() -> Node:
	if _Player and is_instance_valid(_Player):
		return _Player
	else:
		var player_node = get_tree().current_scene.get_node_or_null("Viewport/main/entities/player")
		if player_node:
			_Player = player_node
			return _Player
		else:
			return null

func _on_chalk_draw(origin, size, color):
	if get_player_node():
		get_player_node()._paint(_options['ChalkSize'], color)

func _ready():
	add_to_group("HooksGroup")
