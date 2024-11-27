extends Control

@onready var start_port: LineEdit = %StartPort
@onready var join_ip: LineEdit = %JoinIP
@onready var join_port: LineEdit = %JoinPort

@onready var start_button: Button = %StartButton
@onready var start_sub: HBoxContainer = %StartSub
@onready var join_button: Button = %JoinButton
@onready var join_sub: HBoxContainer = %JoinSub



func _on_start_button_pressed() -> void:
	start_button.hide()
	start_sub.show()
	pass # Replace with function body.


func _on_join_button_pressed() -> void:
	join_button.hide()
	join_sub.show()
	pass # Replace with function body.


func _on_join_confirm_pressed() -> void:
	if(join_ip.text!="IP"):
		GM.obj_server_ip = join_ip.text
		GM.obj_server_port = int(join_port.text)
	GM.switch_scene("res://scenes/main_scene.tscn")
	pass # Replace with function body.


func _on_start_confirm_pressed() -> void:
	if(start_port.text!="端口"):
		GM.as_server_port = int(start_port.text)
	GM.as_server = true
	GM.switch_scene("res://scenes/main_scene.tscn")
	pass # Replace with function body.
