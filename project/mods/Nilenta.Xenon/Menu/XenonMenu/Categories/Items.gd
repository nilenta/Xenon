extends Node

var _Player: Node
var _PlayerData: Node
var _Globals: Node
var xenon_interface: VBoxContainer
var _Network: Node

func setup(Player: Node, PlayerData: Node, Globals: Node, Interface: VBoxContainer, Data, _tree, Network, _posData, PopupMsg, bd) -> void:
	_Player = Player
	_PlayerData = PlayerData
	_Globals = Globals
	xenon_interface = Interface
	_handle_items_list()

func _handle_items_list() -> void:
	for item in _Globals.item_data:
		print("[XENON_GD]: Item ", item, " found.")
		var button = Button.new()
		button.text = item
		button.connect("pressed", self, "_add_item", [item])
		xenon_interface.add_child(button)

func _add_item(item: String) -> void:
	_PlayerData._add_item(item)
	_PlayerData._send_notification("(XENON): Gave player " + item)
