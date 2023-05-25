class_name Player
extends Node2D

signal energy_changed(new_energy)

@onready var rayCastBottom = $RayCast2DBottom
@onready var rayCastPrepareLanding = $RayCast2DPrepareLanding
@onready var rayCastTop = $RayCast2D2Top
@onready var _animated_sprite = $AnimatedSprite2D
const thunder_attack_scn = preload("res://effects/thunder_attack.tscn")
const explosion_scn = preload("res://effects/explosion.tscn")

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
var is_switching_form = false
var is_casted_off = true

var jump_speed = 500
var gravity = 200
var y_vel = 0
var max_y_vel = 300
var jumping = false

var bounds_bw
var bounds_fw
var bounds_uw
var bounds_dw

func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _physics_process(delta):
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var attack = Input.is_action_just_pressed("attack")
	var switch_form = Input.is_action_pressed("switch_form")
	
	if is_switching_form:
		if is_casted_off:
			play("put_on")
			await _animated_sprite.animation_finished
			is_casted_off = false
		else:
			play("cast_off")
			await _animated_sprite.animation_finished
			is_casted_off = true
		is_switching_form = false
	elif is_casted_off:
		if up and not ceil_touched:
			if is_landing:
				play("prepare_landing")
			else:
				play("fly_up")
			position.y -= jump_speed * delta
		elif down and not grounded:
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
	else:
		if not grounded and not jumping:
			y_vel = min(max_y_vel, y_vel+gravity)
			play("cocoon_walk")
			grounded = false
		elif up and grounded:
			y_vel = -jump_speed
			jumping = true
		elif not up:
			jumping = false
		position.y += y_vel * delta
		
	if attack:
		thunder_attack(ceil_touched)

	if switch_form:
		is_switching_form = true
		
	if rayCastBottom.is_colliding():
		var orig = rayCastBottom.global_transform.origin
		var coll = rayCastBottom.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(rayCastBottom.target_position.y - dist)
		grounded = true
		is_landing = false
		ceil_touched = false
		jumping = false
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
	var hitbox = get_child(2)
	remove_child(hitbox)
	var explosion_inst = explosion_scn.instantiate()
	add_child(explosion_inst)
	await explosion_inst.animation_finished
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
