class_name XenonButton
extends GenericUIButton


func _on_xenon_pressed() -> void:
	get_parent().get_parent().get_node("xenon_menu").visible = true
	return
