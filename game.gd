extends Node2D

var segments = [
	preload("res://segments/A.tscn"),
	preload("res://segments/B.tscn"),
	preload("res://segments/C.tscn"),
]

var speed = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	spawn_inst(0, 0)
	spawn_inst(1024, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	for area in $Areas.get_children():
		area.position.x -= speed * delta
		if area.position.x < -1024 - speed * delta:
			spawn_inst(area.position.x+2048, 0)
			area.queue_free()

func spawn_inst(x, y):
	var inst = segments[randi() % len(segments)].instantiate()
	inst.position = Vector2(x, y)
	$Areas.add_child(inst)
