extends Node
class_name GMC

var as_server:bool = false
var as_server_port:int = 7788
var obj_server_ip:String = "127.0.0.1"
var obj_server_port:int = 7788

var current_scene = null  #当前场景
func _ready() -> void:
	var root = get_tree().root #获取根节点
	current_scene = root.get_child(root.get_child_count() - 1) #设置当前场景

#场景切换函数,第一个参数表示切换到对应场景的路径，参数二表示人公出现的位置
func switch_scene(res_path):
	call_deferred("_deferred_switch_scene", res_path)
	#在空闲时调用该对象的_deferred_switch_scene方法。始终返回 null，不返回该方法的结果。

#真正切换场景函数,第一个参数表示切换到对应场景的路径，参数二表示人公出现的位置
func _deferred_switch_scene(res_path):
	current_scene.free()#释放当前场景
	var scene = load(res_path)#载入新场景
	current_scene = scene.instantiate()
	get_tree().root.add_child(current_scene)#将场景添加到根目录	
	get_tree().current_scene = current_scene#当前场景设置为新的场景
	pass

var last_func_time:Dictionary
@export var game_time:int = 0
func _on_timer_timeout() -> void:
	game_time += 1
	pass # Replace with function body.
