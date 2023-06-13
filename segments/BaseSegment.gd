extends StaticBody2D

var y_up_border = 0
var x_left_border = 0
@onready var x_right_border = get_viewport_rect().size.x
@onready var y_down_border = get_viewport_rect().size.y
@onready var y_underground = $DigableGround.position.y + $DigableGround/CollisionShape2D.shape.size.y/2
@onready var y_underground_border = $DigableGround.position.y
@onready var step = $Step
var has_step = false

var enemies = [
	preload("res://enemies/bee_enemy.tscn"),
	preload("res://enemies/caucasus_enemy.tscn"),
	preload("res://enemies/drake_dragonfly_enemy.tscn"),
	preload("res://enemies/kick_hopper_enemy.tscn"),
	preload("res://enemies/punch_hopper_enemy.tscn"),
	preload("res://enemies/sasword_scorpion_enemy.tscn"),
	preload("res://enemies/worm_enemy.tscn"), #spawn in underground only
]

var items = [
	preload("res://pickup-items/lightning_item.tscn"),
	preload("res://pickup-items/score_item.tscn"),
	preload("res://pickup-items/stamina_leaf_item.tscn"), #Should not spawn in underground
]

var spawned_positions = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if step:
		has_step = true
	if has_step:
		var x_end_of_step = step.position.x + step.shape.size.x
		var y_end_of_step = step.position.y + step.shape.size.y
	var spawn_item_times = randi() % 4 + 1
	print(spawn_item_times)
	for i in spawn_item_times:
		spawn_item()
		spawn_enemy()
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_item():
	var index = randi() % len(items)
	var x_position = randi() % int(x_right_border)
	var y_position = randi() % int(y_down_border)
	if index == items.size() - 1 and y_underground_border < y_position:#spawn leaf above underground
		y_position -= abs(y_underground_border - y_position) + 50
	elif y_position >= y_underground_border + $DigableGround/CollisionShape2D.shape.size.y:
		y_position = y_underground_border + $DigableGround/CollisionShape2D.shape.size.y
	var inst = items[index].instantiate()
	#check around positions for duplicate
	var smaller_position = Vector2(x_position, y_position)/1.1
	var larger_position = Vector2(x_position, y_position)*1.1
	var duplicate_position = spawned_positions.filter(func (position):
		return smaller_position.x <= position.x and position.x <= larger_position.x and smaller_position.y <= position.y and position.y <= larger_position.y
	)
	if duplicate_position:
		spawn_item()
	inst.position = Vector2(x_position, y_position)
	add_child(inst)
	spawned_positions.push_back(inst.position)

func spawn_enemy():
	var index = randi() % len(enemies)
	var x_position = randi() % int(x_right_border)
	var y_position = randi() % int(y_down_border)
	if index == enemies.size() - 1:#spawn worm underground
		y_position = y_underground
	elif y_underground_border < y_position:
		y_position -= abs(y_underground_border - y_position)
	#check around positions for duplicate
	var smaller_position = Vector2(x_position, y_position)/1.1
	var larger_position = Vector2(x_position, y_position)*1.1
	var duplicate_position = spawned_positions.filter(func (position):
		return smaller_position.x <= position.x and position.x <= larger_position.x and smaller_position.y <= position.y and position.y <= larger_position.y
	)
	if duplicate_position:
		spawn_enemy()
	var inst = enemies[index].instantiate()
	inst.position = Vector2(x_position, y_position)
	add_child(inst)
	spawned_positions.push_back(inst.position)
