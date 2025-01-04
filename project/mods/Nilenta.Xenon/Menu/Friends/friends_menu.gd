extends Node

const FRIEND_PANEL = preload("res://mods/Nilenta.Xenon/Menu/Friends/friends_panel.tscn")
const TOOLTIP_NODE = preload("res://Scenes/Singletons/Tooltips/tooltip_node.tscn")

onready var main_menu := get_parent()
onready var _PlayerData = get_node("/root/PlayerData")
onready var _PopupMessage = get_node("/root/PopupMessage")
onready var _Globals = get_node("/root/Globals")
onready var _Network = get_node("/root/Network")

var avatar_buffers: Dictionary = {}

onready var interface := $"Panel/Panel2/ScrollContainer/VBoxContainer"
onready var refresh_button := $"Panel/refresh"

func _ready():
	print("[XENON_GD]: Initializing Friends Menu")
	Steam.connect("avatar_loaded", self, "_on_loaded_avatar")
	refresh_button.connect("pressed", self, "_on_refresh_pressed")
	_load_friends()

func _load_friends() -> void:
	for child in interface.get_children():
		interface.remove_child(child)
		child.queue_free()

	var lobbies = _get_friends_in_lobbies()
	
	print(lobbies)
	for plr in lobbies:
		var steam_id = plr
		var game_id = lobbies[plr]
		print(Steam.getLobbyGameServer(game_id))
		var panel = FRIEND_PANEL.instance()
		var avatar = yield(_get_steam_av(steam_id), "completed")
		var avatar_image = Image.new()
		avatar_image.create_from_data(64, 64, false, Image.FORMAT_RGBA8, avatar)
		var avatar_texture = ImageTexture.new()
		avatar_texture.create_from_image(avatar_image)
		panel.get_node("VBoxContainer/HBoxContainer/UserIcon").texture = avatar_texture

		var lobby_name = Steam.getLobbyData(game_id, "name")
		panel.get_node("VBoxContainer/HBoxContainer/Info1/Name").bbcode_text = "[color=#3498db]" + Steam.getFriendPersonaName(steam_id) + "[/color] is in:"
		panel.get_node("VBoxContainer/HBoxContainer/Info1/ServerName").bbcode_text = "[color=#2ecc71]" + lobby_name + "'s Server[/color]"
		var lbtype = Steam.getLobbyData(game_id, "type") 
		match lbtype:
			"public":
				panel.get_node("VBoxContainer/HBoxContainer/Info1/ServerType").bbcode_text = "[color=#1abc9c]Public Server[/color]"
			"code_only":
				panel.get_node("VBoxContainer/HBoxContainer/Info1/ServerType").bbcode_text = "[color=#1abc9c]Code Only Server[/color]"
			"friends_only":
				panel.get_node("VBoxContainer/HBoxContainer/Info1/ServerType").bbcode_text = "[color=#1abc9c]Friends Only Server[/color]"
			_:
				panel.get_node("VBoxContainer/HBoxContainer/Info1/ServerType").bbcode_text = "[color=#1abc9c]??? Server[/color]"

		panel.get_node("VBoxContainer/HBoxContainer/Info2/Code").bbcode_text = "[color=#ff5733]CODE: " + Steam.getLobbyData(game_id, "code") + "[/color]"
		panel.get_node("VBoxContainer/HBoxContainer/Info2/PlayerCount").bbcode_text = "[color=#9b59b6]" + str(Steam.getNumLobbyMembers(game_id)) + "/" + str(Steam.getLobbyMemberLimit(game_id)) + " players[/color]"
		
		panel.get_node("VBoxContainer/JoinGame").connect("pressed", self, "_connect_lobby", [game_id])
		interface.add_child(panel)

func _on_close_pressed() -> void:
	print("[XENON_GD]: Closing Friends menu.")
	main_menu.get_node("friends_menu").visible = false

func _on_refresh_pressed() -> void:
	print("[XENON_GD]: Refreshing Friends menu.")
	avatar_buffers = {}
	_load_friends()

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
			print(lobby)
			print(Steam.getLobbyData(lobby, "code"))
			print(Steam.getLobbyOwner(lobby))
			results[steam_id] = lobby

	return results

func _connect_lobby(code: int) -> void:
	_Network._connect_to_lobby(code)

func _get_steam_av(steam_id: int) -> PoolByteArray:
	Steam.getPlayerAvatar(2, steam_id)
	yield(_wait_for_avatar(steam_id), "completed")
	return avatar_buffers.get(steam_id, PoolByteArray())

func _wait_for_avatar(steam_id: int) -> void:
	while not avatar_buffers.has(steam_id):
		yield(get_tree(), "idle_frame")
	emit_signal("completed")

func _on_loaded_avatar(user_id: int, avatar_size: int, buffer: PoolByteArray) -> void:
	avatar_buffers[user_id] = buffer
