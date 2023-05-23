class_name Player
extends Node2D

signal energy_changed(new_energy)

@onready var rayCastBottom = $RayCast2DBottom
@onready var rayCastPrepareLanding = $RayCast2DPrepareLanding
@onready var rayCastTop = $RayCast2D2Top
@onready var _animated_sprite = $AnimatedSprite2D
var thunder_attack_scn = preload("res://effects/thunder_attack.tscn")

@export var max_energy := 9
var energy := max_energy :
	set(value):
		energy = clamp(value, 0, max_energy)
		emit_signal("energy_changed", value)
	get: 
		return energy

var grounded = false
var ceil_touched = false
var is_landing = false

var gravity = 15
var jump_speed = 500

func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _physics_process(delta):
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var attack = Input.is_action_just_pressed("attack")
	
	if up and not ceil_touched and position.y > 0:
		if is_landing:
			play("prepare_landing")
		else:
			play("fly_up")
		position.y -= jump_speed * delta
	elif down and not grounded and position.y < 648:
		play("fly_down")
		position.y += jump_speed * delta
	elif grounded:
		play("walk")
	elif ceil_touched:
		play("walk", false, true)
	elif is_landing:
		play("prepare_landing")
	else: 
		play("fly_forward")

	if attack:
		thunder_attack(ceil_touched)

	if rayCastBottom.is_colliding():
		var orig = rayCastBottom.global_transform.origin
		var coll = rayCastBottom.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(rayCastBottom.target_position.y - dist)
		grounded = true
		is_landing = false
		ceil_touched = false
		position.y -= depth
	else:
		grounded = false
		
	if rayCastTop.is_colliding():
		var orig = rayCastTop.global_transform.origin
		var coll = rayCastTop.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(rayCastTop.target_position.y + dist)
		ceil_touched = true
		grounded = false
		position.y += depth
	else:
		ceil_touched = false
		
	if rayCastPrepareLanding.is_colliding():
		is_landing = true
		grounded = false
	else:
		is_landing = false

func _on_hit_box_body_entered(body: BaseEnemy):
	print("body entered")
	queue_free()

func thunder_attack(ceil_touched: bool):
	if energy >= 3:
		energy -= 3
		var thunder_attack_inst = thunder_attack_scn.instantiate()
		thunder_attack_inst.position = Vector2(_animated_sprite.position)
		var _attack_sprite = thunder_attack_inst.get_child(1)
		add_child(thunder_attack_inst)
		_attack_sprite.set_flip_v(ceil_touched)
		_attack_sprite.play("default")
		await _attack_sprite.animation_finished
		remove_child(thunder_attack_inst)
