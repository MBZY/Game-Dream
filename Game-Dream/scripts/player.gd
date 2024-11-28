extends CharacterBody2D
class_name Player

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	pass

signal hit_face

func _ready():
	var viewport_rect = get_viewport_rect()
	global_position = Vector2(randf_range(0,viewport_rect.size.x),randf_range(0,viewport_rect.size.y))
	print(self)
	pass
	
@onready var ani: AnimatedSprite2D = %Ani
@onready var hp_bar: ProgressBar = %Hp_Bar
@onready var player: Player = $"."


@export var player_move_gap_duration:int = 1
@export var player_rebound_gap_duration:int = 5
@export var player_rebound_re_gap_duration:int = 5
@export var shooter_max_speed:int = 1000
@export var shooter_max_length:int = 100
@export var shooter_speed:int = 800
@export var shooter_speed_common_reduction:int = 1
@export var max_hp:int = 100
@export var hp:int = 100
@export var now_velocity:Vector2 = Vector2.ZERO

func PL_MOVE():
	var PLMOVE_ID = "PL_MOVE"+str(name.to_int())
	
	if(not GM.last_func_time.has(PLMOVE_ID)):
		GM.last_func_time[PLMOVE_ID]=0
	elif(GM.game_time-GM.last_func_time[PLMOVE_ID]>=player_move_gap_duration):
		GM.last_func_time[PLMOVE_ID] = GM.game_time
		ani.rotation_degrees+=1
	pass
	

func attribute_ui_refresh():
	hp_bar.value = hp
	hp_bar.max_value = max_hp
	pass

var f:bool = false
func _process(_delta):
	PL_MOVE()
	attribute_ui_refresh()
	shooter_check()
	rebound_grid_refresh()
	if(is_multiplayer_authority()):
		velocity = now_velocity
		if(f):
			print(velocity)
			f=false
		move_and_slide()
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
	var pvlen = now_velocity.length()
	if(shooter.points.size()>=2):
		now_velocity = shooter_speed * (shooter.points[1]-shooter.points[0]).normalized()\
			*(shooter.points[1]-shooter.points[0]).length()/shooter_max_length
	if(pvlen!=0):	
		move_and_slide()
		if(pvlen>=shooter_speed_common_reduction):
			now_velocity = (pvlen-shooter_speed_common_reduction)*now_velocity.normalized()
			print(now_velocity)
		else:
			now_velocity = Vector2.ZERO
	pass

func shooter_run():
	var pvlen = now_velocity.length()
	if(pvlen!=0):	
		if(pvlen>=shooter_speed_common_reduction):
			now_velocity = (pvlen-shooter_speed_common_reduction)*now_velocity.normalized()
		else:
			now_velocity = Vector2.ZERO
	
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

var is_rebound_grid:Dictionary

func rebound_grid_refresh():
	var REBOUND_RE_ID = "REBOUND_RE"+str(name.to_int())
	if(not GM.last_func_time.has(REBOUND_RE_ID)):
		GM.last_func_time[REBOUND_RE_ID]=0
	elif(GM.game_time-GM.last_func_time[REBOUND_RE_ID]>=player_rebound_re_gap_duration):
		is_rebound_grid = {}
	pass

func a2c_do(area:Area2D):
	if is_multiplayer_authority() and area.is_in_group("Colli"):
		var REBOUND_ID = "REBOUND"+str(name.to_int())
		
		var body = area.get_parent()
		
		if(not GM.last_func_time.has(REBOUND_ID)):
			GM.last_func_time[REBOUND_ID]=0
		elif(GM.game_time-GM.last_func_time[REBOUND_ID]>=player_rebound_gap_duration):
			if(is_rebound_grid.has(name) and is_rebound_grid[name] == body.name):
				return;
			print(REBOUND_ID)
			is_rebound_grid[name] = body.name
			is_rebound_grid[body.name] = name
			
			GM.last_func_time[REBOUND_ID] = GM.game_time
			hit_face.emit()
			if(shooter_max_speed>=body.now_velocity.length() and shooter_max_speed>=now_velocity.length()):
				var temp = body.now_velocity
				body.plus_now_velocity(now_velocity)
				now_velocity = temp-now_velocity
	pass
func plus_now_velocity(v:Vector2):
	now_velocity+=v
	pass
func _on_area_2_check_area_entered(area: Area2D) -> void:
	if(is_multiplayer_authority()):
		a2c_do(area)
	pass # Replace with function body.

@rpc("authority","call_local")
func hit_face_do():
	ani.play("awake")
	await get_tree().create_timer(GM.tick_time*3).timeout
	ani.play("after_awake")
	await get_tree().create_timer(GM.tick_time*10).timeout
	ani.play("default")
	pass
func _on_hit_face() -> void:
	hit_face_do.rpc()
	pass # Replace with function body.
