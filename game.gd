extends Node2D

@onready var _energy_bar: Control = $EnergyBar
@onready var _player: Player = $Player
@onready var _areas: Node2D = $Areas
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

const underground_dirt_scn = preload("res://effects/under_ground_effect.tscn")
var segments = [
	preload("res://segments/A.tscn"),
	preload("res://segments/B.tscn"),
	preload("res://segments/C.tscn"),
]
var current_segment_index = 0

var speed = 200   
# Called when the node enters the scene tree for the first time.
func _ready():
	if _player and _energy_bar:
		_player.connect("energy_changed", _energy_bar.set_energy)
		_player.connect("walk_underground", add_underground_effect)
		_player.connect("ground_landing", add_underground_effect)
	randomize()
	spawn_inst(0, 0)
	spawn_inst(bounds_fw, 0)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	#after the character is moved clamp its position to the end of the camera bounds
	if _player:
		_player.global_position.x = clamp(_player.global_position.x, bounds_bw, bounds_fw)
		_player.global_position.y = clamp(_player.global_position.y, bounds_uw, bounds_dw)

	var player_position = _player.global_transform.origin
	for area in _areas.get_children():
		area.position.x -= speed * delta
		if area.position.x < -bounds_fw - speed * delta:
			spawn_inst(area.position.x + bounds_fw * 2, 0)
			area.queue_free()
		if area.position.x + bounds_fw > player_position.x and area.position.x < player_position.x:
			current_segment_index = area.get_index()

func spawn_inst(x, y):
	var index = randi() % len(segments)
	var inst = segments[index].instantiate()
	inst.position = Vector2(x, y)
	_areas.add_child(inst)
	
func add_underground_effect(is_entering, walking, is_exiting, is_landing) -> bool:
	var segment_index = current_segment_index
	var old_dirt_effect = _areas.get_child(segment_index).get_child(-1) #The last index will be equal to the dirt effect
	var regex = RegEx.new()
	regex.compile("underGroundEffect")
	var matchNodeName = regex.search(old_dirt_effect.name)
	
	var dirt_effect = underground_dirt_scn.instantiate()
	var segment_position = _areas.get_child(segment_index).global_transform.origin
	var player_position = _player.global_transform.origin
	var player_height = _player.get_node("CollisionShape2D").shape.height
	var animation_name = "default"
		
	#init new dirt effect if there's no dirt node or old node has finished the animation
	if walking and (!matchNodeName || matchNodeName and not old_dirt_effect.is_playing()):
		dirt_effect.position = player_position - segment_position
		_areas.get_child(segment_index).add_child(dirt_effect)
	elif is_entering or is_exiting:
		if is_entering:
			animation_name = "enter"
			dirt_effect.position = player_position - segment_position + Vector2(0, player_height/1.5)
		elif is_exiting:
			animation_name = "exit"
			dirt_effect.position = player_position - segment_position - Vector2(0, player_height/7)
	elif is_landing and (!matchNodeName || matchNodeName and not old_dirt_effect.is_playing()):
		animation_name = "ground_landing"
		dirt_effect.position = player_position - segment_position
	_areas.get_child(segment_index).add_child(dirt_effect)
	dirt_effect.play(animation_name)
	return true
	
