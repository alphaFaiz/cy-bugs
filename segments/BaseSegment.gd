extends StaticBody2D

var y_up_border = 0
var x_left_border = 0

@onready var underground_width = $DigableGround/CollisionShape2D.shape.size.x
@onready var underground_height = $DigableGround/CollisionShape2D.shape.size.y
@onready var x_right_border = get_viewport_rect().size.x
@onready var y_down_border = get_viewport_rect().size.y - underground_height
@onready var y_spawn_underground = $DigableGround.position.y + $DigableGround/CollisionShape2D.shape.size.y/2
@onready var y_underground_border = $DigableGround.position.y
@onready var step = $Step
@onready var x_end_of_step = 0
@onready var y_end_of_step = 0
@onready var solid_ground = {
	"start": Vector2($CollisionShape2D.position.x, $CollisionShape2D.position.y),
	"end": Vector2($CollisionShape2D.position.x + $CollisionShape2D.shape.size.x, $CollisionShape2D.position.y + $CollisionShape2D.shape.size.y)
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
var unavailable_item_positions = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if step:
		has_step = true
	if has_step:
		x_end_of_step = step.position.x + step.shape.size.x
		y_end_of_step = step.position.y + step.shape.size.y
#		print("start_of_step: ", step.position.x, ", ", step.position.y, "|end_of_step:", x_end_of_step, ", ", y_end_of_step)
#		print("y_underground_border: ", y_underground_border)
	var spawn_item_times = randi() % 6 + 1
	var spawn_enemy_times = randi() % 4 + 1
	generate_spawn_positions()
#	print("spawn_item_times: ", spawn_item_times)
#	print("spawn_enemy_times: ", spawn_enemy_times)
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
				"end": step.position.y
			}, 
			{
				"start": y_end_of_step,
				"end": y_down_border
			}
		]
		var range_index = randi() % len(spawn_y_ranges)
		y_position = randi() % int(spawn_y_ranges[range_index].end) + spawn_y_ranges[range_index].start
		var step_position_condition = (y_position + inst_radius >= step.position.y and y_position + inst_radius <= y_end_of_step)
		var ground_position_condition = (y_position + inst_radius >= step.position.y and y_position + inst_radius <= y_end_of_step)
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
		pass 
	elif enemy.underground_enemy:
		pass
	else:
		inst.position = spawn_cells[cell_index].center
		add_child(inst)
		spawn_cells.remove_at(index)

func spawn_old_enemy():
	var index = randi() % len(enemies)
	var enemy = enemies[index]
	var x_position = randi() % int(x_right_border) + 1
	var y_position = randi() % int(y_down_border) + 1
	var inst = enemy.src.instantiate()
	#get instance height
	var inst_height = 0;
	if inst.get_node("CollisionShape2D").shape is RectangleShape2D:
		inst_height = inst.get_node("CollisionShape2D").shape.size.y
	elif inst.get_node("CollisionShape2D").shape is CapsuleShape2D:
		inst_height = inst.get_node("CollisionShape2D").shape.radius
		
	if has_step:
		#divide 2 or 3 (or maybe 4) areas (above the step, under the step, next to the step), 
		#random to select one of the area and spawn it
		var spawn_y_ranges = [
			{
				"start": 0,
				"end": step.position.y
			}, 
			{
				"start": y_end_of_step,
				"end": y_down_border
			}
		]
		var range_index = randi() % len(spawn_y_ranges)
		y_position = randi() % int(spawn_y_ranges[range_index].end) + spawn_y_ranges[range_index].start
			
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
		if smaller_position.x <= position_vector.x and position_vector.x <= larger_position.x and smaller_position.y <= position_vector.y and position_vector.y <= larger_position.y:
#			print("enemy duplicate with others:", position_vector)
			return true
	)
	if duplicate_position:
		spawn_enemy()
	else:
		inst.position = Vector2(x_position, y_position)
#		print(enemy.name, ": ", inst.position)
		add_child(inst)
		unavailable_positions.push_back(inst.position)

func generate_spawn_positions():
	var viewport = get_viewport_rect().size
#	var viewport_width = viewport.x
#	var viewport_height = viewport.y
	var number_of_collums = 8
	var number_of_rows = 5

	var cell_width = floor(viewport.x/number_of_collums)
	var cell_height = floor(viewport.y/number_of_rows)

	for i in number_of_collums:
		var x_position = (i + 1) * cell_width / 2
		for j in number_of_rows:
			var y_position = (j + 1) * cell_height
			spawn_cells.push_back({
				"start": Vector2(i * cell_width, j * cell_height),
				"center": Vector2((i + 1) * cell_width / 2, (j + 1) * cell_height / 2),
				"end": Vector2((i + 1) * cell_width, (j + 1) * cell_height),
				"is_underground": false
			})
	#filter cells that duplicated with the ground
	spawn_cells = spawn_cells.filter(func(cell):
			var is_duplicated = check_duplicate_with_the_solid_ground(cell)
			if is_duplicated:
				return false
			return true
	)
	print("after filter cells: ", spawn_cells.size())
	if has_step:
		print("before: ", spawn_cells.size())
		spawn_cells = spawn_cells.filter(func(cell): 
			var is_duplicated = check_duplicate_with_steps(cell)
			if is_duplicated:
				return false
			return true
		)

func check_duplicate_with_steps(cell):
	var step_head_inside_the_cell = cell.start.x <= step.position.x and step.position.x <= cell.end.x
	var step_tail_inside_the_cell = cell.start.x <= x_end_of_step and x_end_of_step <= cell.end.x
	var step_go_through_the_cell = step.position.x <= cell.start.x and cell.start.x <= x_end_of_step
	
	if step_head_inside_the_cell or step_tail_inside_the_cell or step_go_through_the_cell:
		if cell.start.y <= step.position.y and step.position.y <= cell.end.y:
			return true
		elif step.position.y <= cell.start.y and cell.start.y <= y_end_of_step:
			return true
		elif step.position.y <= cell.end.y and cell.end.y <= y_end_of_step:
			return true
		return false
	return false

func check_duplicate_with_the_solid_ground(cell):
	var ground_head_inside_the_cell = cell.start.x <= solid_ground.start.x and solid_ground.start.x <= cell.end.x
	var ground_tail_inside_the_cell = cell.start.x <= solid_ground.end.x and solid_ground.end.x <= cell.end.x
	var ground_go_through_the_cell = solid_ground.start.x <= cell.start.x and cell.start.x <= solid_ground.end.x
	
	if ground_head_inside_the_cell or ground_tail_inside_the_cell or ground_go_through_the_cell:
		if cell.start.y <= solid_ground.start.y and solid_ground.start.y <= cell.end.y:
			return true
		elif solid_ground.start.y <= cell.start.y and cell.start.y <= solid_ground.end.y:
			return true
		elif solid_ground.start.y <= cell.end.y and cell.end.y <= solid_ground.end.y:
			return true
		return false
	return false
