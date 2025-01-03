extends "res://mods/Nilenta.Xenon/Components/Classes/MenuCategory.gd"

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var _Network: Node
var xenon_panels_data: Array = []
var parentTree
var _PopupMessage: Node

var SERVER_CREATION_TYPE = 0;

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, pop) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	parentTree = _tree
	_PopupMessage = pop
	
	register_option("SetLobbyCode", "")
	register_option("SetPublicity", "Public")
	register_option("MaxPlayers", 12)
	register_option("Plus18", false)
	register_option("SetLobbyName", "")
	
	
	
	xenon_panels_data = [
		{
			"name": "Lobby Code",
			"description": "yo lobby code",
			"elements": [
				{"type": "string", "name": "SetLobbyCode", "initial_value": _options["SetLobbyCode"], "key": "SetLobbyCode"},
			]
		},
		{
			"name": "Lobby Name",
			"description": "mot required",
			"elements": [
				{"type": "string", "name": "SetLobbyName", "initial_value": _options["SetLobbyName"], "key": "SetLobbyName"},
			]
		},
		{
			"name": "Lobby Type",
			"description": "u want public? or CODE ONly",
			"elements": [
				{"type": "dropdown", "name": "SetPublicity", "options": ["Public", "Code Only", "Friends Only"], "initial_value": _options["SetPublicity"], "key": "SetPublicity"},
			]
		},
		{
			"name": "Max Players",
			"description": "Yeah",
			"elements": [
				{"type": "integer", "name": "MaxPlayers", "initial_value": _options["MaxPlayers"], "key": "MaxPlayers"},
			]
		},
		
		{
			"name": "18+",
			"description": "Whyat do u think./",
			"elements": [
				{"type": "boolean", "name": "Plus18", "initial_value": _options["Plus18"], "key": "Plus18"},
			]
		},
		
	]
	_load_panels()

func _load_panels() -> void:
	for panel_info in xenon_panels_data:
		_add_panel_to_interface(panel_info)
	var button3 = Button.new()
	button3.text = "Create Lobby"
	button3.connect("pressed", self, "_replacethislater")
	xenon_interface.add_child(button3)


func _replacethislater() -> void:
	if _options["SetLobbyCode"] == "" or _options["SetLobbyCode"].length() > 6: 
		_PopupMessage._show_popup("Lobby code cannot be blank or more than 6 characters")
		return # F CUCK
	if _options["MaxPlayers"] < 1: 
		_PopupMessage._show_popup("Max players can only be 1 or greater.")
		return # hhhhh
	_options["SetLobbyCode"] = _options["SetLobbyCode"].to_upper()
	
	var doesExist = yield(_check_if_lobby_exists(_options["SetLobbyCode"]), "completed")
	if doesExist:
		# oh it exists
		print(doesExist)
		_PopupMessage._show_popup("There is already a lobby with this code.")
		return
	
	# disconnect the network creating thing temp
	Steam.disconnect("lobby_created", _Network, "_on_Lobby_Created")
	Steam.connect("lobby_created", self, "_on_Lobby_Created")
	createLobby() 
	_Globals._enter_game()
	yield(parentTree.create_timer(4), "timeout")
	Steam.disconnect("lobby_created", self, "_on_Lobby_Created")
	Steam.connect("lobby_created", _Network, "_on_Lobby_Created")
	
func createLobby() -> void:
	var type = 0
	if _options["SetPublicity"] == "Code Only": type = 1 # i T HINK THIS IS CORECT
	if _options["SetPublicity"] == "Friends Only": type = 2
	SERVER_CREATION_TYPE = type
	
	_Network.SERVER_CREATION_TYPE = type
	_Network._reset_lobby_status()
	
	if _Network.STEAM_LOBBY_ID == 0:
		_Network.GAME_MASTER = true
		
		var lobby_type = Steam.LOBBY_TYPE_PUBLIC
		match type:
			0: lobby_type = Steam.LOBBY_TYPE_PUBLIC
			1: lobby_type = Steam.LOBBY_TYPE_INVISIBLE
			2: lobby_type = Steam.LOBBY_TYPE_FRIENDS_ONLY
		
		_PlayerData.players_blocked.clear()
		Steam.createLobby(lobby_type, _options["MaxPlayers"])


func _on_Lobby_Created(connect, lobby_id):
	if connect != 1: return 
	var code = _options["SetLobbyCode"]
	code = code.to_upper()
	_Network.LOBBY_CODE = code
	
	
	var lobby_type = ["public", "code_only", "friends_only"][SERVER_CREATION_TYPE]
	var joinable = lobby_type == "public"
	var public = "true" if lobby_type == "public" else "false"
	var age_limit = "true" if _options["Plus18"] else ""
	
	_Network.CODE_ENABLED = lobby_type == "code_only" or lobby_type == "public"
	_Network.PLAYING_OFFLINE = false
	
	_Network.STEAM_LOBBY_ID = lobby_id
	_Network._update_chat("Created Lobby.")
	Steam.setLobbyJoinable(lobby_id, true)
	Steam.setLobbyData(lobby_id, "name", str(_Network.STEAM_USERNAME))
	Steam.setLobbyData(lobby_id, "lobby_name", str(_options["SetLobbyName"] if _options["SetLobbyName"].length() > 0 else str(_Network.STEAM_USERNAME) + "'s Lobby"))
	Steam.setLobbyData(lobby_id, "ref", "webfishing_gamelobby")
	Steam.setLobbyData(lobby_id, "version", str(Globals.GAME_VERSION))
	Steam.setLobbyData(lobby_id, "code", code)
	Steam.setLobbyData(lobby_id, "type", lobby_type)
	Steam.setLobbyData(lobby_id, "age_limit", age_limit)
	Steam.setLobbyData(lobby_id, "public", public)
	Steam.setLobbyData(lobby_id, "cap", str(_options["MaxPlayers"]))
	Steam.setLobbyData(lobby_id, "banned_players", "")
	Steam.allowP2PPacketRelay(true)
	
	
	Steam.setLobbyData(lobby_id, "server_browser_value", str(0))


func _check_if_lobby_exists(code):
	# I SHOULD HAVE ADDED THIS IN 1.1.0
	# NVM REMAKE FOR 1.1.2 CAUSE V1.09 BROKE IT
	var lobby_found = false
	
	code = code.to_upper()
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("code", str(code), Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	var lobbies = yield (Steam, "lobby_match_list")
	print(lobbies)
	if lobbies.size() > 0:
		lobby_found = true
		print("Lobby found with code ", code)

	return lobby_found
