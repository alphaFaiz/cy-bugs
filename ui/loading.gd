extends Node

@onready var loading_screen = preload("res://ui/loading_screen.tscn")
var progress = []
@onready var scene = null
@onready var progress_bar = null
@onready var loading_screen_inst = null

func _process(delta):
	if scene and scene != null:
		var status = ResourceLoader.load_threaded_get_status(scene, progress)
		progress_bar.value = progress[0] * 100.0
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			pass
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene_resource = ResourceLoader.load_threaded_get(scene)
			get_tree().change_scene_to_packed(scene_resource)
			loading_screen_inst.queue_free()
			scene = null
			progress_bar = null
			loading_screen_inst = null
		else:
			scene = null
			progress_bar = null
			loading_screen_inst = null
			print("error occured while loading chunks of data")

func load_scene(current_scene, next_scene, loading_screen):
	if not loading_screen:
		loading_screen_inst = loading_screen.instantiate()
	else:
		loading_screen_inst = loading_screen
		loading_screen.show()
	scene = next_scene
	progress_bar = loading_screen_inst.get_node("ProgressBar")
	get_tree().get_root().call_deferred("add_child", loading_screen_inst)
	
	var loader = ResourceLoader.load_threaded_request(scene)
	if loader != OK:
		print("error occured while getting the scene:", loader)
		return
#	current_scene.queue_free()
