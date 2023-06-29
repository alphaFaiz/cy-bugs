extends Node

@onready var loading_screen = preload("res://ui/loading_screen.tscn")
var progress = []

func load_scene(current_scene, next_scene):
	var loading_screen_inst = loading_screen.instantiate()
	var progress_bar = loading_screen_inst.get_node("ProgressBar")
	get_tree().get_root().call_deferred("add_child", loading_screen_inst)
	
	var loader = ResourceLoader.load_threaded_request(next_scene)
	if loader != OK:
		print("error occured while getting the scene:", loader)
		return
	current_scene.queue_free()
	
	while true:
		var status = ResourceLoader.load_threaded_get_status(next_scene, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100.0
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			print("loaded")
			var scene = ResourceLoader.load_threaded_get(next_scene)
			get_tree().change_scene_to_packed(scene)
			loading_screen_inst.queue_free()
			return
		else:
			print("error occured while loading chunks of data")
			return
