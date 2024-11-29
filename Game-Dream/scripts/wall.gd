extends CharacterBody2D
class_name Wall

@onready var colli: CollisionShape2D = %Colli
@onready var shape: Line2D = %Shape
@onready var colli_2: CollisionShape2D = %Colli2

@export var first_point:Vector2 = Vector2.ZERO
@export var last_point:Vector2 = Vector2.ZERO

@export var be_stastic:bool = false
var first_paint:bool = false

var ruin_start_game_time:int
@export var duration:int = 100
func self_ruin_check():
	if(GM.game_time - ruin_start_game_time >= duration):
		self.queue_free()
	else:
		self.modulate.a8 = 255*(1.0-float(GM.game_time-ruin_start_game_time)/float(duration))
	pass

func _process(delta: float) -> void:
	if(first_point!=null and last_point!=null):
		var tempshape:SegmentShape2D = SegmentShape2D.new()
		tempshape.a = first_point
		tempshape.b = last_point
		colli.shape = tempshape
		colli_2.shape = tempshape
	
	if(not be_stastic or not first_paint):
		var temppoints:PackedVector2Array
		temppoints.append(first_point)
		temppoints.append(last_point)
		shape.points = temppoints
		first_paint = true
		ruin_start_game_time = GM.game_time
		
	self_ruin_check()
	pass
