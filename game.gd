extends Node2D

@onready var _energy_bar: Control = $EnergyBar
@onready var _player: Player = $Player
#get the viewport size and divide by 2 since this is where the camera is positioned
@onready var view = get_viewport_rect().size / 2
#get the camera position
@onready var camera_pos = $Camera2D.global_position
@onready var bounds_bw = camera_pos.x - view.x #the camera bounds at the back
@onready var bounds_fw = camera_pos.x + view.x #the camera bounds at the front
@onready var bounds_uw = camera_pos.y - view.y #the camera bounds at the top
@onready var bounds_dw = camera_pos.y + view.y #the camera bounds at the bottom

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
	randomize()
	spawn_inst(0, 0)
	spawn_inst(1024, 0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	#after the character is moved clamp its position to the end of the camera bounds
	if _player:
		_player.global_position.x = clamp(_player.global_position.x, bounds_bw, bounds_fw)
		_player.global_position.y = clamp(_player.global_position.y, bounds_uw, bounds_dw)

	for area in $Areas.get_children():
		area.position.x -= speed * delta
		if area.position.x < -1024 - speed * delta:
			spawn_inst(area.position.x+2048, 0)
			area.queue_free()

func spawn_inst(x, y):
	var inst = segments[randi() % len(segments)].instantiate()
	inst.position = Vector2(x, y)
	$Areas.add_child(inst)
