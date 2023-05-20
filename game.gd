extends Node2D

@onready var _energy_bar: Control = $EnergyBar
@onready var _player: Player = $Player

var pickup_items = [
	preload("res://pickup-items/lightning_item.tscn")
]

var segments = [
	preload("res://segments/A.tscn"),
	preload("res://segments/B.tscn"),
	preload("res://segments/C.tscn"),
]

var speed = 200
# Called when the node enters the scene tree for the first time.
func _ready():
	if _player and _energy_bar:
		_player.connect("energy_changed", _energy_bar.set_energy)
		#"energy_changed", set_energy
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
