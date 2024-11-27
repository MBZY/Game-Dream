extends CharacterBody2D
class_name Player

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	pass


func _ready():
	var viewport_rect = get_viewport_rect()
	global_position = Vector2(randf_range(0,viewport_rect.size.x),randf_range(0,viewport_rect.size.y))
	pass
	
@onready var ani: AnimatedSprite2D = %Ani
@onready var hp_bar: ProgressBar = %Hp_Bar
@onready var player: Player = $"."


@export var player_move_gap_duration:int = 1
@export var shooter_max_length:int = 100
@export var shooter_speed:int = 800
@export var shooter_speed_common_reduction:int = 1
@export var max_hp:int = 100
@export var hp:int = 100

@rpc("authority","call_local")
func PL_MOVE():
	var PLMOVE_ID = "PL_MOVE"+str(multiplayer.get_unique_id())
	
	if(not GM.last_func_time.has(PLMOVE_ID)):
		GM.last_func_time[PLMOVE_ID]=0
		
	elif(GM.game_time-GM.last_func_time[PLMOVE_ID]>=player_move_gap_duration):
		GM.last_func_time[PLMOVE_ID] = GM.game_time
		ani.rotation_degrees += 1
		print(ani,ani.rotation_degrees)
	pass
	

func attribute_ui_refresh():
	hp_bar.value = hp
	hp_bar.max_value = max_hp
	pass
	
func _process(_delta):
	PL_MOVE.rpc()
	attribute_ui_refresh()
	if not is_multiplayer_authority():
		return
	shooter_check()
	pass

@onready var shooter: Line2D = %Shooter
var is_mouse_in:bool =false
var is_mouse_triggered:bool = false
func _input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and is_mouse_in:
			is_mouse_triggered = true
			#print(1)
		if event.button_index == MOUSE_BUTTON_LEFT and !event.is_pressed() and !is_mouse_in:
			is_mouse_triggered = false
	pass
func _on_area_2_check_mouse_entered() -> void:
	if not is_multiplayer_authority():
		return
	is_mouse_in = true
	pass # Replace with function body.
func _on_area_2_check_mouse_exited() -> void:
	if not is_multiplayer_authority():
		return
	is_mouse_in = false
	pass # Replace with function body.
	
func shooter_shoot(): 
	var pvlen = player.velocity.length()
	if(shooter.points.size()>=2):
		player.velocity = shooter_speed * (shooter.points[1]-shooter.points[0]).normalized()\
			*(shooter.points[1]-shooter.points[0]).length()/shooter_max_length
	if(pvlen!=0):	
		move_and_slide()
		if(pvlen>=shooter_speed_common_reduction):
			player.velocity = (pvlen-shooter_speed_common_reduction)*player.velocity.normalized()
			print(player.velocity)
		else:
			player.velocity = Vector2.ZERO
	pass

func shooter_run():
	var pvlen = player.velocity.length()
	if(pvlen!=0):	
		move_and_slide()
		if(pvlen>=shooter_speed_common_reduction):
			player.velocity = (pvlen-shooter_speed_common_reduction)*player.velocity.normalized()
		else:
			player.velocity = Vector2.ZERO
	
	var viewport_rect = get_viewport_rect()
	if(player.global_position.x >= viewport_rect.size.x):
		player.global_position.x -= viewport_rect.size.x
	elif(player.global_position.x < 0):
		player.global_position.x += viewport_rect.size.x
	if(player.global_position.y >= viewport_rect.size.y):
		player.global_position.y -= viewport_rect.size.y
	elif(player.global_position.y < 0):
		player.global_position.y += viewport_rect.size.y
	pass

var first_after_shoot:bool = false
func shooter_check():
	if(is_mouse_triggered):
		var pack_vector:PackedVector2Array
		pack_vector.append(Vector2(0,0))
		
		var local_mouse_position = get_local_mouse_position()
		if(local_mouse_position.length() >= shooter_max_length):
			pack_vector.append(local_mouse_position.normalized()*shooter_max_length)
		else:
			pack_vector.append(local_mouse_position)
		shooter.points = pack_vector
		shooter.show()
		first_after_shoot = true
	else:
		shooter.hide()
		if(first_after_shoot):
			shooter_shoot()
			first_after_shoot = false
		else:
			shooter_run()
	pass
