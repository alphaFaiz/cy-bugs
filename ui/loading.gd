extends Node

@onready var loading_screen = preload("res://ui/loading_screen.tscn")
var progress = []
@onready var scene = null
@onready var progress_bar = null
@onready var loading_screen_inst = null

func _process(delta):
	if scene and scene != null:
		var status = ResourceLoader.load_threaded_get_status(scene, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100.0
			return
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene_resource = ResourceLoader.load_threaded_get(scene)
			get_tree().change_scene_to_packed(scene_resource)
			loading_screen_inst.queue_free()
			scene = null
			progress_bar = null
			loading_screen_inst = null
			return
		else:
			scene = null
			progress_bar = null
			loading_screen_inst = null
			print("error occured while loading chunks of data")
			return

func load_scene(current_scene, next_scene):
	scene = next_scene
	loading_screen_inst = loading_screen.instantiate()
	progress_bar = loading_screen_inst.get_node("ProgressBar")
	get_tree().get_root().call_deferred("add_child", loading_screen_inst)
	
	var loader = ResourceLoader.load_threaded_request(scene)
	if loader != OK:
		print("error occured while getting the scene:", loader)
		return
	current_scene.queue_free()
	
#	while true:
#		var status = ResourceLoader.load_threaded_get_status(scene, progress)
#		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
#			progress_bar.value = progress[0] * 100.0
#			print(progress_bar.value)
#			return
#		elif status == ResourceLoader.THREAD_LOAD_LOADED:
#			print("loaded")
#			var scene = ResourceLoader.load_threaded_get(scene)
#			get_tree().change_scene_to_packed(scene)
#			loading_screen_inst.queue_free()
#			return
#		else:
#			print("error occured while loading chunks of data")
#			return
