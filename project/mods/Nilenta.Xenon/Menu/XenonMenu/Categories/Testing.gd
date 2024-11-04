extends "res://mods/Nilenta.Xenon/Components/Classes/MenuCategory.gd"

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var _Network: Node
var xenon_panels_data: Array = []
var parentTree

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	_Network = Network
	xenon_interface = Interface
	parentTree = _tree
	
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


func _replacethislater() -> void:
	var player_pos = _Player.global_transform.origin
	# _Network._send_P2P_Packet({"type": "ban", "new_host": "0"}, "all", 2) # this is a bad thing maybe  i should report this
	# _Network._send_P2P_Packet({"type": "message", "message": "asfsdafhasdlfhsdjkahfsdjalfhjkasdlhfkljasdkljfhasdkjfhasdfkljhasdfkljhasdflkjhasdfkjlhasdfkjhasdfkjhlasdfkhjasdfljkhasdfkjhlasdfkhasdfkjhasdfkhjasdfkjhasdfkjhasdfkjhasdfkljhasdfkhljasdfkhljfasdkhljfasdkhljfasdkhljfaskhljsdfakhljfasdkhljfasdkhljfasdkhljfasdkhljasdfhljkfasdkhljfasdhljkasdfkhljfasdkhljfaskhljfaskhljfasdkhljfasdkhljdfaskhljfasdhljkasdfhjklfasdkhljfasdkhlj", "sender": 1, "local": false, "position": _Player.global_transform.origin, "zone": "Global", "zone_owner": 1}, "all", 2)
	#_Network._send_P2P_Packet({"type": "player_punch", "from": Vector3(0,0,0), "player": 1, "punch_type": 1}, "all", 2)
	#_Network._send_P2P_Packet({"type": "new_player_join", "player_id": 76561198207248827}, "all", 2)
	# print("[X]:", _Network.OWNED_ACTORS)
	#_Network._send_P2P_Packet({"type": "recieve_host", "host_id": 76561198207248827}, "all", 2)
	# _Player._sync_sfx("rain", player_pos, 4)
	# _Player.global_transform.origin = Vector3(0,1666,0)
	#print()
	#Steam.setLobbyData(_Network.STEAM_LOBBY_ID, "code", "POOP")
	#print("SET ID")
	print(Steam.getLobbyData(_Network.STEAM_LOBBY_ID, "code"))
	#_Network._send_P2P_Packet({"type": "actor_request_send", "list": data, "host": true, "user_id": _Network.STEAM_ID}, "all", 2, 1)
	pass
