extends "res://mods/Nilenta.Xenon/Components/Classes/MenuCategory.gd"

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var _Network: Node
var xenon_panels_data: Array = []
var parentTree
var avatar_buffers: Dictionary = {}

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	parentTree = _tree
	Steam.connect("avatar_loaded", self, "_on_loaded_avatar")
	
	#register_option("SpawnAmount", 1)
	
	var hooks_nodes = _tree.get_nodes_in_group("HooksGroup")
	if hooks_nodes.size() > 0:
		hooks = hooks_nodes[0]
		_options = hooks._get_options()
		hooks._set_player(_Player)
	
	xenon_panels_data = []
	
	_load_panels()

func _load_panels() -> void:
	for panel_info in xenon_panels_data:
		_add_panel_to_interface(panel_info)
	var button3 = Button.new()
	button3.text = "test"
	button3.connect("pressed", self, "_replacethislater")
	xenon_interface.add_child(button3)


func _get_friends_in_lobbies() -> Dictionary:
	var results: Dictionary = {}

	for i in range(0, Steam.getFriendCount()):
		var steam_id: int = Steam.getFriendByIndex(i, Steam.FRIEND_FLAG_IMMEDIATE)
		var game_info: Dictionary = Steam.getFriendGamePlayed(steam_id)
		if game_info.empty():
			continue
		else:
			var app_id: int = game_info['id']
			var lobby = game_info['lobby']
			

			if app_id != Steam.getAppID() or lobby is String:
				continue
			
			results[steam_id] = lobby

	return results

func _replacethislater() -> void:
	#var lobbies = _get_friends_in_lobbies()
	#for lobby in lobbies.values():
	#	var lobby_code = Steam.getLobbyData(lobby, "code")
	#	print(lobby_code)
		#_Network._connect_to_lobby(lobby)
	for cosmetic in _Globals.cosmetic_data:
		_PlayerData._unlock_cosmetic(cosmetic)
	pass

func _get_steam_av(steam_id: int) -> PoolByteArray:
	Steam.getPlayerAvatar(2, steam_id)
	yield(_wait_for_avatar(steam_id), "completed")
	return avatar_buffers.get(steam_id, PoolByteArray())

func _wait_for_avatar(steam_id: int) -> void:
	while not avatar_buffers.has(steam_id):
		yield(parentTree, "idle_frame")

	print("Avatar buffer for Steam ID %s is now ready." % steam_id)
	emit_signal("completed")

func _on_loaded_avatar(user_id: int, avatar_size: int, buffer: PoolByteArray) -> void:
	print("Avatar loaded for user: %s" % user_id)
	print("Size: %s" % avatar_size)
	avatar_buffers[user_id] = buffer
