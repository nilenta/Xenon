extends "res://mods/Nilenta.Xenon/Components/Classes/MenuCategory.gd"

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var _Network: Node
var xenon_panels_data: Array = []
var parentTree

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg, bd) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	parentTree = _tree
	
	register_option("SpawnAmount", 1)
	register_option("SpawnType", "player")
	register_option("SpawnOffsetX", 0)
	register_option("SpawnOffsetY", 0)
	register_option("SpawnOffsetZ", 0)
	register_option("SpawnSteamId", 0)
	
	var hooks_nodes = _tree.get_nodes_in_group("HooksGroup")
	if hooks_nodes.size() > 0:
		hooks = hooks_nodes[0]
		_options = hooks._get_options()
		hooks._set_player(_Player)
	
	xenon_panels_data = [
		{
			"name": "Object",
			"description": "object u wana spawn",
			"elements": [
				{"type": "dropdown", "name": "SpawnType", "options": ["void_portal", "player", "tent", "loose_object", "fish_spawn", "fish_spawn_deep", "fish_spawn_alien", "raincloud", "aqua_fish", "ambient_bird", "picnic", "canvas", "bush", "rock", "fish_trap", "fish_trap_ocean", "island_tiny", "island_med", "island_big", "boombox", "well", "campfire", "chair", "table", "therapist_chair", "toilet", "whoopie", "beer", "greenscreen"], "initial_value": _options["SpawnType"], "key": "SpawnType"},
			]
		},
		{
			"name": "Amount",
			"description": "amount u wanna spawmn",
			"elements": [
				{"type": "float", "name": "SpawnAmount", "initial_value": _options["SpawnAmount"], "key": "SpawnAmount"},
			]
		},
		{
			"name": "Offset (X, Y, Z)",
			"description": "offset from your character",
			"elements": [
				{"type": "float", "name": "SpawnOffsetX", "initial_value": _options["SpawnOffsetX"], "key": "SpawnOffsetX"},
				{"type": "float", "name": "SpawnOffsetY", "initial_value": _options["SpawnOffsetY"], "key": "SpawnOffsetY"},
				{"type": "float", "name": "SpawnOffsetZ", "initial_value": _options["SpawnOffsetZ"], "key": "SpawnOffsetZ"},
			]
		},
		{
			"name": "Steam ID",
			"description": "spawns under a steam id, if you dont know what this does just leave it as 0",
			"elements": [
				{"type": "float", "name": "SpawnSteamId", "initial_value": _options["SpawnSteamId"], "key": "SpawnSteamId"},
			]
		}
	]
	
	_load_panels()

func _load_panels() -> void:
	for panel_info in xenon_panels_data:
		_add_panel_to_interface(panel_info)
	var button = Button.new()
	button.text = "Spawn"
	button.connect("pressed", self, "_spawn_test")
	xenon_interface.add_child(button)
	var button2 = Button.new()
	button2.text = "Spawn Randomly Around Player"
	button2.connect("pressed", self, "_spawn_rand")
	xenon_interface.add_child(button2)
	var button3 = Button.new()
	button3.text = "Spawn Raincloud"
	button3.connect("pressed", self, "_spawn_rain")
	xenon_interface.add_child(button3)
	var button4 = Button.new()
	button4.text = "Spawn Meteor"
	button4.connect("pressed", self, "_spawn_meatball")
	xenon_interface.add_child(button4)
	

# FUNCS
func _spawn_rand() -> void:
	var current_zone = _PlayerData.player_saved_zone
	if current_zone == "":
		current_zone = "main_zone" # fallback
	var player_pos = _Player.global_transform.origin
	
	# curse you 1.09
	var steamid = _Network.STEAM_ID
	if _options["SpawnSteamId"] > 0:
		steamid = _options["SpawnSteamId"]
	
	for i in _options["SpawnAmount"]:
		var pos = player_pos + Vector3(rand_range(-2.5, 2.5), rand_range(-2.5, 2.5), rand_range(-2.5, 2.5))
		_Network._sync_create_actor(_options["SpawnType"], pos, current_zone, -1, steamid)
	_PlayerData._send_notification("(XENON): Spawned " + str(_options["SpawnAmount"]) + " of " + _options["SpawnType"] + " around yourself.")

func _spawn_test() -> void:
	var current_zone = _PlayerData.player_saved_zone
	if current_zone == "":
		current_zone = "main_zone" # fallback
	
	# curse you 1.09
	var steamid = _Network.STEAM_ID
	if _options["SpawnSteamId"] > 0:
		steamid = _options["SpawnSteamId"]
	
	var player_pos = _Player.global_transform.origin
	for i in _options["SpawnAmount"]:
		var pos = player_pos + Vector3(_options["SpawnOffsetX"], _options["SpawnOffsetY"], _options["SpawnOffsetZ"])
		_Network._sync_create_actor(_options["SpawnType"], pos, current_zone, -1, steamid)
	_PlayerData._send_notification("(XENON): Spawned " + str(_options["SpawnAmount"]) + " of " + _options["SpawnType"])

func _spawn_rain() -> void:
	var pos = Vector3(rand_range( - 100, 150), 42, rand_range( - 150, 100))
	_Network._sync_create_actor("raincloud", pos, "main_zone", -1, _Network.STEAM_ID)
	_PlayerData._send_notification("(XENON): Spawned raincloud")

func _spawn_meatball() -> void:
	var current_zone = _PlayerData.player_saved_zone
	if current_zone == "":
		current_zone = "main_zone" # fallback
	var point = parentTree.get_nodes_in_group("fish_spawn")[randi() % parentTree.get_nodes_in_group("fish_spawn").size()]
	
	var pos = point.global_transform.origin
	_Network._sync_create_actor("fish_spawn_alien", pos, current_zone, -1, _Network.STEAM_ID)
	_PlayerData._send_notification("(XENON): Spawned meteor")

