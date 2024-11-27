extends Control


func _on_start_button_pressed() -> void:
	GM.as_server = true
	GM.switch_scene("res://scenes/main_scene.tscn")
	pass # Replace with function body.
