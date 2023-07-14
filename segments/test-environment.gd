extends StaticBody2D
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var call_spawn = Input.is_action_just_pressed("ui_accept")
	#0: the bee , 1: caucasus, 2: drake, 3: kick hopper, 4: punch hopper, 5: sasword, 6: worm
	#normal position: Vector2(747, 483) , underground: Vector2(747, 583)
	if call_spawn:
		var enemy = enemies[3]
		var inst = enemy.src.instantiate()
		inst.position = Vector2(747, 483)
		add_child(inst, true)
	pass
