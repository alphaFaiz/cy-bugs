class_name Player
extends CharacterBody2D

signal energy_changed(new_energy)
signal crash_to_wall

@onready var rayCastBottom = $RayCast2DBottom
@onready var rayCastPrepareLanding = $RayCast2DPrepareLanding
@onready var rayCastTop = $RayCast2D2Top
@onready var _animated_sprite = $AnimatedSprite2D
const thunder_attack_scn = preload("res://effects/thunder_attack.tscn")
const explosion_scn = preload("res://effects/explosion.tscn")
@onready var stable_position = position.x

@export var max_energy := 9
var energy := max_energy :
	set(value):
		energy = clamp(value, 0, max_energy)
		emit_signal("energy_changed", value)
	get: 
		return energy

var grounded = false
var undergrounded = false
var ceil_touched = false
var jumping = false
var is_ceil_landing = false
var is_switching_form = false
var is_casted_off = true
var crashed = false

var jump_speed = 500
var gravity = 200
var y_vel = 0
var max_y_vel = 300

func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _physics_process(delta):
	var down = Input.is_action_pressed("ui_down")
	var attack = Input.is_action_just_pressed("attack")
	var switch_form = Input.is_action_pressed("switch_form")
	var skill = Input.is_action_just_pressed("skill")
	
	if position.x < stable_position and not crashed:
		if abs(position.x - stable_position) >=1:
			crashed = true
			destroy()
		else:
			position.x = stable_position	

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
		var up = Input.is_action_pressed("ui_up")
		if up and not ceil_touched:
			if is_ceil_landing:
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
		elif is_ceil_landing:
			play("prepare_landing")
		else: 
			play("fly_forward")
		if skill: #clock up
			$CollisionShape2D.disabled = !$CollisionShape2D.disabled
			$HitBox/CollisionShape2D2.disabled = !$HitBox/CollisionShape2D2.disabled
	else:
		var up = Input.is_action_just_pressed("ui_up")
		if not grounded and not jumping:
			y_vel = min(max_y_vel, y_vel+gravity)
			position.y += y_vel * delta
#			grounded = false
		elif up and undergrounded:
			y_vel = -jump_speed * 4
			jumping = true
			position.y += y_vel * delta
			undergrounded = false
		elif down and grounded:
			undergrounded = true
#			rayCastBottom.collision_mask = 2
		elif not up:
			play("cocoon_walk")
			jumping = false
		
		
#		if grounded and rayCastBottom.collision_mask == 2:
#
#			undergrounded = true
#		else:
#			undergrounded = false
		if undergrounded:
			print(grounded, rayCastBottom.collision_mask == 2)
			rayCastBottom.collision_mask = 2
		else:
			rayCastBottom.collision_mask = 1
		
#	move_and_collide(velocity * delta)
	move_and_slide()
	
	if attack:
		thunder_attack(ceil_touched)

	if switch_form and not undergrounded:
		is_switching_form = true
		
	if rayCastBottom.is_colliding():
		var orig = rayCastBottom.global_transform.origin
		var coll = rayCastBottom.get_collision_point()
		var dist = abs(orig.y - coll.y)
		var depth = abs(rayCastBottom.target_position.y - dist)
		position.y -= depth - 1
		grounded = true
		is_ceil_landing = false
		ceil_touched = false
		jumping = false
	else:
		grounded = false
				
	if rayCastPrepareLanding.is_colliding():
		is_ceil_landing = true
		grounded = false
		jumping = false
	else:
		is_ceil_landing = false
	
	if rayCastTop.is_colliding():
		var orig = rayCastTop.global_transform.origin
		var coll = rayCastTop.get_collision_point()
		var dist = abs(orig.y - coll.y)
		#rayCastTop.target_position.y is the position of the arrow - equal to the length of raycast
		var depth = abs(rayCastTop.target_position.y + dist)
		position.y += depth - 1
		ceil_touched = true
		is_ceil_landing = false
		grounded = false
	else:
		ceil_touched = false

func _on_hit_box_body_entered(body: BaseEnemy):
	crashed = true
	destroy()

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
 
func destroy() -> void:
	var hitbox = get_child(2)
	remove_child(hitbox)
	var explosion_inst = explosion_scn.instantiate()
	add_child(explosion_inst)
	await explosion_inst.animation_finished
	queue_free()
