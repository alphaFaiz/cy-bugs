class_name Player
extends Node2D

signal energy_changed(new_energy)

@onready var rayCastBottom = $RayCast2DBottom
@onready var rayCastPrepareLanding = $RayCast2DPrepareLanding
@onready var rayCastTop = $RayCast2D2Top
@onready var _animated_sprite = $AnimatedSprite2D

@export var max_energy := 9
var energy := 1

var grounded = false
var ceil_touched = false
var is_landing = false

var gravity = 15
var jump_speed = -500

var max_y_vel = 300
var y_vel = 0

func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _physics_process(delta):
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
		
	if up and not ceil_touched:
		if is_landing:
			play("prepare_landing")
		else:
			play("fly_up")
		position.y += jump_speed * delta
	elif down and not grounded:
		play("fly_down")
		position.y -= jump_speed * delta
	elif grounded:
		play("walk")
	elif ceil_touched:
		play("walk", false, true)
	elif is_landing:
		play("prepare_landing")
	else: 
		play("fly_forward")

	position.y += y_vel * delta

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

func set_energy(new_energy: int) -> void:
	energy = clamp(new_energy, 0, max_energy)
	emit_signal("energy_changed", new_energy)

func _on_hit_box_body_entered(body):
	queue_free()
