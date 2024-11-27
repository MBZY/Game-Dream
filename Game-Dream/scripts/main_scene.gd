extends Node2D


const PLAYER = preload("res://scenes/player.tscn")
@onready var players: Node = $Players

var peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
func init_server():
	var error = peer.create_server(7788)
	if(error != OK):
		printerr("创建服务器失败，错误码",error)
		return
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	add_player(multiplayer.get_unique_id())
	pass
func add_player(id:int):
	var player = PLAYER.instantiate()
	player.name = str(id)
	players.add_child(player)
	pass
func _on_peer_connected(id:int):
	
	pass



@onready var bg: TextureRect = %BG

func _ready():
	bg.position = Vector2.ZERO
	bg.size = get_window().get_visible_rect().size
	bg.pivot_offset = bg.size/2
	bg.pivot_offset = bg.size/2
	if(GM.as_server):
		init_server()
	pass
	
@export var bg_move_gap_duration:int = 1
@export var bg_move_speed:float = 0.01
var is_negative_symbol:bool = false
func BG_MOVE():
	if(not GM.last_func_time.has("BG_MOVE")):
		GM.last_func_time["BG_MOVE"]=0
	elif(GM.game_time-GM.last_func_time["BG_MOVE"]>=bg_move_gap_duration):
		GM.last_func_time["BG_MOVE"] = GM.game_time
		if(is_negative_symbol):
			bg.scale.x -= bg_move_speed
			bg.scale.y -= bg_move_speed
		else:
			bg.scale.x += bg_move_speed
			bg.scale.y += bg_move_speed
		if(bg.scale.x >= 1.9 and not is_negative_symbol):
			is_negative_symbol = true
		if(bg.scale.x <= 1 and is_negative_symbol):
			is_negative_symbol = false
	pass

func _process(_delta):
	BG_MOVE()
	pass
