extends StaticBody2D

var y_up_border = 0
var x_left_border = 0

@onready var underground_width = $DigableGround/CollisionShape2D.shape.size.x
@onready var underground_height = $DigableGround/CollisionShape2D.shape.size.y
@onready var x_right_border = get_viewport_rect().size.x
@onready var y_down_border = get_viewport_rect().size.y - underground_height
@onready var y_spawn_underground = $DigableGround.position.y + $DigableGround/CollisionShape2D.shape.size.y * 0.5
@onready var y_underground_border = $DigableGround.position.y
@onready var step = {
	"start": Vector2(0, 0),
	"end": Vector2(0, 0)
}
@onready var solid_ground = {
	"start": Vector2($CollisionShape2D.position.x - $CollisionShape2D.shape.size.x * 0.5, $CollisionShape2D.position.y - $CollisionShape2D.shape.size.y * 0.5),
	"end": Vector2($CollisionShape2D.position.x + $CollisionShape2D.shape.size.x * 0.5, $CollisionShape2D.position.y + $CollisionShape2D.shape.size.y * 0.5)
}
var spawn_cells = []
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
	},
	{
		"name": "score",
		"src": preload("res://pickup-items/score_item.tscn"),
	},
	{
		"name": "score",
		"src": preload("res://pickup-items/stamina_leaf_item.tscn"),
	}
]

var unavailable_positions = []
var unavailable_ground_x = []
var unavailable_item_positions = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $Step:
		has_step = true
	if has_step:
		step.start.x = $Step.position.x - $Step.shape.size.x * 0.5
		step.start.y = $Step.position.y - $Step.shape.size.y * 0.5
		step.end.x = $Step.position.x + $Step.shape.size.x * 0.5
		step.end.y = $Step.position.y + $Step.shape.size.y * 0.5
		print("step range: ", step.start, " - ", step.end, $Step.shape.size)
	var spawn_item_times = randi() % 6 + 1
	var spawn_enemy_times = randi() % 6 + 1
	generate_spawn_positions()
#	print("spawn_item_times: ", spawn_item_times)
#	print("spawn_enemy_times: ", spawn_enemy_times, solid_ground)
	for i in spawn_enemy_times:
		spawn_enemy()
	for i in spawn_item_times:
		spawn_item()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_item():
	var index = randi() % len(items)
	var item = items[index]
	var x_position = randi() % int(x_right_border) + 1
	var y_position = randi() % int(y_down_border) + 1
	var inst = items[index].src.instantiate()
	#get instance height
	var inst_radius = inst.get_node("CollisionShape2D").shape.radius
	if has_step:
		#divide 2 or 3 (or maybe 4) areas (above the step, under the step, next to the step), 
		#random to select one of the area and spawn it
		var spawn_y_ranges = [
			{
				"start": 0,
				"end": step.start.y
			}, 
			{
				"start": step.end.y,
				"end": y_down_border
			}
		]
		var range_index = randi() % len(spawn_y_ranges)
		y_position = randi() % int(spawn_y_ranges[range_index].end) + spawn_y_ranges[range_index].start
		var step_position_condition = (y_position + inst_radius >= step.start.y and y_position + inst_radius <= step.end.y)
		var ground_position_condition = (y_position + inst_radius >= step.start.y and y_position + inst_radius <= step.end.y)
		if step_position_condition:
			y_position -= 2 * inst_radius
	if y_underground_border < y_position:
		y_position = y_spawn_underground
	if y_spawn_underground > y_position and y_underground_border < y_position + inst_radius:
		y_position -= 2 * inst_radius
	#check around positions for duplicate
	var smaller_position = Vector2(x_position, y_position)/1.2
	var larger_position = Vector2(x_position, y_position)*1.2
	var duplicate_position = unavailable_item_positions.filter(func (position_vector):
		if smaller_position.x <= position_vector.x and position_vector.x <= larger_position.x and smaller_position.y <= position_vector.y and position_vector.y <= larger_position.y:
#			print("item duplicate with other items:", position_vector)
			return true
	)
	if duplicate_position:
		spawn_item()
	else:
		inst.position = Vector2(x_position, y_position)
		add_child(inst)
		unavailable_item_positions.push_back(inst.position)

func spawn_enemy():
	var index = randi() % len(enemies)
	var enemy = enemies[index]
	var cell_index = randi() % len(spawn_cells)
	var inst = enemy.src.instantiate()
	if enemy.ground_enemy:
#		print("157:", unavailable_ground_x)
		var ground_cells = spawn_cells.filter(func(cell): return cell.in_ground_range and len(unavailable_ground_x.filter(func(x): return cell.center.x == x)) == 0)
#		print("ground cells length:", len(ground_cells), " - ", ground_cells.map(func(cell): return cell.center.x))
		cell_index = spawn_cells.find(ground_cells.pick_random(), 0)
		inst.position = spawn_cells[cell_index].center
	elif enemy.underground_enemy:
		var useable_cells = spawn_cells.filter(func(cell): return not cell.above_the_step and cell.in_ground_range)
		cell_index = spawn_cells.find(useable_cells.pick_random(), 0)
		inst.position = spawn_cells[cell_index].center
		inst.position.y = y_spawn_underground
	else:
		inst.position = spawn_cells[cell_index].center
	unavailable_ground_x.push_back(spawn_cells[cell_index].center.x)	
	add_child(inst)
#	print(enemy.name, " |cell_index: ", cell_index, " |position: ", spawn_cells[cell_index].center)
	spawn_cells.remove_at(cell_index)

func generate_spawn_positions():
	var viewport = get_viewport_rect().size
	var number_of_collums = 16
	var number_of_rows = 10

	var cell_width = floor(viewport.x/number_of_collums)
	var cell_height = floor(viewport.y/number_of_rows)
	print("cell width:", cell_width, " | cell_height:", cell_height)
	
	for i in number_of_collums:
		for j in number_of_rows:
			var new_cell = {
				"start": Vector2(i * cell_width, j * cell_height),
				"center": Vector2((0.5 + i) * cell_width, (0.5 + j) * cell_height),
				"end": Vector2((i + 1) * cell_width, (j + 1) * cell_height),
				"above_the_step": has_step and (j + 0.5) * cell_height < step.start.y,
				"in_ground_range": solid_ground.start.x < (0.5 + i) * cell_width and (0.5 + i) * cell_width < solid_ground.end.x
			}
			spawn_cells.push_back(new_cell)

	#filter cells that duplicated with the ground
	spawn_cells = spawn_cells.filter(func(cell):
			var is_duplicated = check_duplicate_with_the_solid_ground(cell)
			if is_duplicated:
				return false
			return true
	)
	if has_step:
		spawn_cells = spawn_cells.filter(func(cell): 
			var is_duplicated = check_duplicate_with_steps(cell)
			if is_duplicated:
				return false
			return true
		)
#	for i in len(spawn_cells):
#		var line = Line2D.new()
#		add_child(line)
#		line.width = 1
#		line.add_point(spawn_cells[i].start)
#		line.add_point(Vector2(spawn_cells[i].start.x, spawn_cells[i].end.y))
#		line.add_point(spawn_cells[i].end)
#		line.add_point(Vector2(spawn_cells[i].end.x, spawn_cells[i].start.y))
#		line.add_point(Vector2(spawn_cells[i].start.x + 10, spawn_cells[i].start.y))

func check_duplicate_with_steps(cell):
	var step_head_inside_the_cell = cell.start.x <= step.start.x and step.start.x <= cell.end.x
	var step_tail_inside_the_cell = cell.start.x <= step.end.x and step.end.x <= cell.end.x
	var step_go_through_the_cell = step.start.x <= cell.center.x and cell.center.x <= step.end.x
#	print(step_head_inside_the_cell, " ", step_tail_inside_the_cell, " ", step_go_through_the_cell)
	if step_head_inside_the_cell or step_tail_inside_the_cell or step_go_through_the_cell:
		if cell.start.y <= step.start.y and step.start.y <= cell.end.y:
			return true
		if step.start.y <= cell.start.y and cell.start.y <= step.end.y:
			return true
		if step.start.y <= cell.end.y and cell.end.y <= step.end.y:
			return true
		if step.start.y <= cell.center.y and cell.center.y <= step.end.y:
			return true
	return false

func check_duplicate_with_the_solid_ground(cell):
#	var ground_head_inside_the_cell = cell.start.x <= solid_ground.start.x and solid_ground.start.x <= cell.end.x
#	var ground_tail_inside_the_cell = cell.start.x <= solid_ground.end.x and solid_ground.end.x <= cell.end.x
#	var ground_go_through_the_cell = solid_ground.start.x <= cell.center.x and cell.center.x <= solid_ground.end.x
#	if ground_head_inside_the_cell or ground_tail_inside_the_cell or ground_go_through_the_cell:
#		if cell.start.y <= solid_ground.start.y and solid_ground.start.y <= cell.end.y:
#			return true
#		if solid_ground.start.y <= cell.start.y and cell.start.y <= solid_ground.end.y:
#			return true
#		if solid_ground.start.y <= cell.end.y and cell.end.y <= solid_ground.end.y:
#			return true
#		if solid_ground.start.y <= cell.center.y and cell.center.y <= solid_ground.end.y:
#			return true
	if solid_ground.start.y <= cell.start.y and cell.start.y <= solid_ground.end.y:
		return true
	if solid_ground.start.y <= cell.end.y and cell.end.y <= solid_ground.end.y:
		return true
	if solid_ground.start.y <= cell.center.y and cell.center.y <= solid_ground.end.y:
		return true
	return false
