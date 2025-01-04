class_name FriendsButton
extends GenericUIButton


func _on_friends_pressed() -> void:
	get_parent().get_parent().get_node("friends_menu").visible = true
	return
