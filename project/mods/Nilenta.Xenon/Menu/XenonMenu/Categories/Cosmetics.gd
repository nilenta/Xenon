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
	_handle_cosmetics()

func _handle_cosmetics() -> void:
	for cosmetic in _Globals.cosmetic_data:
		print("[XENON_GD]: Cosmetic ", cosmetic, " found.")
		var button = Button.new()
		button.text = cosmetic
		button.connect("pressed", self, "_add_cosmetic", [cosmetic])
		xenon_interface.add_child(button)

func _add_cosmetic(cosmetic: String) -> void:
	_PlayerData._unlock_cosmetic(cosmetic)
	_PlayerData._send_notification("(XENON): Gave player " + cosmetic)
