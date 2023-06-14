extends StaticBody2D

var y_up_border = 0
var x_left_border = 0
@onready var x_right_border = get_viewport_rect().size.x
@onready var y_down_border = get_viewport_rect().size.y
@onready var underground_width = $DigableGround/CollisionShape2D.shape.size.x
@onready var underground_height = $DigableGround/CollisionShape2D.shape.size.y
@onready var y_spawn_underground = $DigableGround.position.y + $DigableGround/CollisionShape2D.shape.size.y/2
@onready var y_underground_border = $DigableGround.position.y
@onready var step = $Step
@onready var x_end_of_step = 0
@onready var y_end_of_step = 0

var has_step = false

var enemies = [
	{
		"name": "the bee",
		"src": preload("res://enemies/bee_enemy.tscn"),
		"ground_enemy": false,
		"underground_enemy": false,
	},
	{
		"name": "caucasus",
		"src": preload("res://enemies/caucasus_enemy.tscn"),
		"ground_enemy": false,
		"underground_enemy": false,
	},
	{
		"name": "drake",
		"src": preload("res://enemies/drake_dragonfly_enemy.tscn"),
		"ground_enemy": false,
		"underground_enemy": false,
	},
	{
		"name": "kick hopper",
		"src": preload("res://enemies/kick_hopper_enemy.tscn"),
		"ground_enemy": true,
		"underground_enemy": false,
	},
	{
		"name": "punch hopper",
		"src": preload("res://enemies/punch_hopper_enemy.tscn"),
		"ground_enemy": true,
		"underground_enemy": false,
	},
	{
		"name": "sasword",
		"src": preload("res://enemies/sasword_scorpion_enemy.tscn"),
		"ground_enemy": true,
		"underground_enemy": false,
	},
	{
		"name": "worm",
		"src": preload("res://enemies/worm_enemy.tscn"),
		"ground_enemy": false,
		"underground_enemy": true,
	},
]

var items = [
	{
		"name": "energy",
		"src": preload("res://pickup-items/lightning_item.tscn"),
		"can_be_underground": true
	},
	{
		"name": "score",
		"src": preload("res://pickup-items/score_item.tscn"),
		"can_be_underground": true
	},
	{
		"name": "score",
		"src": preload("res://pickup-items/stamina_leaf_item.tscn"),
		"can_be_underground": false
	}
]

var unavailable_positions = []
var unavailable_item_positions = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	if step:
		has_step = true
	if has_step:
		x_end_of_step = step.position.x + step.shape.size.x
		y_end_of_step = step.position.y + step.shape.size.y
		print("start_of_step: ", step.position.x, ", ", step.position.y, "|end_of_step:", x_end_of_step, ", ", y_end_of_step)
		print("y_underground_border: ", y_underground_border)
	var spawn_item_times = randi() % 4 + 1
	var spawn_enemy_times = randi() % 4 + 1
	print("spawn_item_times: ", spawn_item_times)
	print("spawn_enemy_times: ", spawn_enemy_times)
	for i in spawn_enemy_times:
		spawn_enemy()
#	for i in spawn_item_times:
#		spawn_item()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_item():
	randomize()
	var index = randi() % len(items)
	var item = items[index]
	var x_position = randi() % int(x_right_border) + 1
	var y_position = randi() % int(y_down_border) + 1
	var inst = items[index].src.instantiate()
	#get instance height
	var inst_height = inst.get_node("CollisionShape2D").shape.radius
	if has_step:
		var spawn_y_ranges = [step.position.y, y_down_border - y_end_of_step]
		var range_index = randi() % len(spawn_y_ranges.size) + 1
		y_position = randi() % int(spawn_y_ranges[range_index]) + 1
		#divide 3 (or maybe 4) areas (above the step, under the step, next to the step), 
		#random to select one of the area and spawn it
		pass
	if not item.can_be_underground:
		y_position = randi() % int(y_underground_border) + 1
	elif y_underground_border < y_position:
		y_position = y_spawn_underground
#	if has_step:
		
	#check around positions for duplicate
	var smaller_position = Vector2(x_position, y_position)/1.2
	var larger_position = Vector2(x_position, y_position)*1.2
	var duplicate_position = unavailable_item_positions.filter(func (position_vector):
		if has_step and step.position.x <= position_vector.x and position_vector.x <= x_end_of_step and step.position.y <= position_vector.y and position_vector.y <= y_end_of_step:
			print("item duplicate with step:", position_vector)
			return true
		if smaller_position.x <= position_vector.x and position_vector.x <= larger_position.x and smaller_position.y <= position_vector.y and position_vector.y <= larger_position.y:
			print("item duplicate with other items:", position_vector)
			return true
	)
	if duplicate_position:
		randomize()
		spawn_item()
	else:
		inst.position = Vector2(x_position, y_position)
		add_child(inst)
		unavailable_item_positions.push_back(inst.position)

func spawn_enemy():
	var index = randi() % len(enemies)
	var enemy = enemies[index]
	var x_position = randi() % int(x_right_border)
	var y_position = randi() % int(y_down_border)
	var inst = enemy.src.instantiate()
	#get instance height
	var inst_height = 0;
	if inst.get_node("CollisionShape2D").shape is RectangleShape2D:
		inst_height = inst.get_node("CollisionShape2D").shape.size.y
	elif inst.get_node("CollisionShape2D").shape is CapsuleShape2D:
		inst_height = inst.get_node("CollisionShape2D").shape.radius
	
	if enemy.underground_enemy or enemy.ground_enemy:
		x_position = randi() % int(underground_width) + $DigableGround.position.x
	if enemy.underground_enemy:
		y_position = y_spawn_underground
	elif enemy.ground_enemy and has_step and y_position < step.position.y:
		y_position = step.position.y - inst_height/2
	elif enemy.ground_enemy and y_position < y_underground_border:
		y_position = y_underground_border - inst_height/2
	elif y_underground_border < y_position:
		y_position -= abs(y_underground_border - y_position)
	#check around positions for duplicate
	var smaller_position = Vector2(x_position, y_position)/1.5
	var larger_position = Vector2(x_position, y_position)*1.5
		
	var duplicate_position = unavailable_positions.filter(func (position_vector):
		if has_step and step.position.x <= position_vector.x and position_vector.x <= x_end_of_step and step.position.y <= position_vector.y and position_vector.y <= y_end_of_step:
			print("enemy duplicate with step:", position_vector)
			unavailable_positions.push_back(Vector2(x_position, y_position))
			return true
		if smaller_position.x <= position_vector.x and position_vector.x <= larger_position.x and smaller_position.y <= position_vector.y and position_vector.y <= larger_position.y:
			print("enemy duplicate with others:", position_vector)
			return true
	)
	if duplicate_position:
		randomize()
		spawn_enemy()
	else:
		inst.position = Vector2(x_position, y_position)
		print(enemy.name, ": ", inst.position)
		add_child(inst)
		unavailable_positions.push_back(inst.position)
