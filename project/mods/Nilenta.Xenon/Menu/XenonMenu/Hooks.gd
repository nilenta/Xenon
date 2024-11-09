extends Node
class_name Hooks

onready var _PopupMessage = get_node("/root/PopupMessage")
onready var _Player = get_tree().current_scene.get_node_or_null("Viewport/main/entities/player")
onready var _PlayerData = get_node("/root/PlayerData")
var _options = {
	"Message": "",
	"SpawnAmount": 1,
	"SpawnType": "player",
	"SpawnOffsetX": 0,
	"SpawnOffsetY": 0,
	"SpawnOffsetZ": 0,
	"SpawnSteamId": 0,
	"ChalkSize": 2
}

func setup() -> void:
	yield(get_tree().create_timer(1.0), "timeout")
	_PlayerData.connect("_chalk_draw", self, "_chalk_draw")

func on_player_hud(_USERDATA, _baitData) -> void:
	if get_player_node():
		_Player.BAIT_DATA = _baitData.get_bait_data()
		print("NEW BAIT DATA: " + str(_Player.BAIT_DATA))
	pass


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

func _chalk_draw(origin, size, color):
	if get_player_node():
		var csize = _options['ChalkSize']
		if csize > 10: csize = 10 # ljklgdhfshgjkdfshgljksdfjghlkfsdghjkfsdhljgkfsdghljofsdghfdklghdjfkhgjkdfshgjfksd
		get_player_node()._paint(csize, color)

func _ready():
	add_to_group("HooksGroup")
