extends CharacterBody2D
class_name Wall
@onready var colli: CollisionShape2D = %Colli
@onready var shape: Line2D = %Shape
@onready var colli_2: CollisionShape2D = %Colli2

@export var first_point:Vector2 = Vector2.ZERO
@export var last_point:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if(first_point!=null and last_point!=null):
		var tempshape:SegmentShape2D = SegmentShape2D.new()
		tempshape.a = first_point
		tempshape.b = last_point
		colli.shape = tempshape
		colli_2.shape = tempshape
	
	var temppoints:PackedVector2Array
	temppoints.append(first_point)
	temppoints.append(last_point)
	shape.points = temppoints
	pass
