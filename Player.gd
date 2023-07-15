class_name Player
extends CharacterBody2D

signal energy_changed(new_energy)
signal stamina_changed(new_stamina)
signal walk_underground(enter, normal_walk, exit, landing_ground)
signal ground_landing
signal clockup_mode(turned_on, time_left)
signal point_changed(new_point)
signal game_over(current_point)

@onready var rayCastBottom = $RayCast2DBottom
@onready var rayCastPrepareLanding = $RayCast2DPrepareLanding
@onready var rayCastTop = $RayCast2D2Top
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _hitbox = $HitBox
@onready var regenEnergyTimer = $RegenEnergyTimer
@onready var clockupTimer = $ClockupTimer
@onready var putOnAudioPlayer = $PutonAudioPlayer
@onready var castOffAudioPlayer = $CastOffAudioPlayer
@onready var clockUpAudioPlayer = $ClockUpAudioPlayer
@onready var clockOverAudioPlayer = $ClockOverAudioPlayer
@onready var underGroundAudioPlayer = $UnderGroundAudioPlayer

const clockup_speed_scn = preload("res://effects/clock_up_effect.tscn")
const thunder_attack_scn = preload("res://effects/thunder_attack.tscn")
const explosion_scn = preload("res://effects/explosion.tscn")

@onready var stable_position = position.x

@onready var point := 0 :
	set(value):
		point = value
		emit_signal("point_changed", value)
	get: 
		return point

@export var max_energy := 9
var energy := max_energy :
	set(value):
		energy = clamp(value, 0, max_energy)
		emit_signal("energy_changed", value)
	get: 
		return energy

@export var max_stamina := 100.0
var stamina := max_stamina :
	set(value):
		stamina = clamp(value, 0, max_stamina)
		emit_signal("stamina_changed", value)
	get: 
		return stamina

var grounded = false
var entering_underground = false
var exiting_underground = false
var undergrounded = false
var ceil_touched = false
var is_ceil_landing = false
var is_switching_form = false
var is_casted_off = true
var crashed = false
var is_in_speed_force = false
var is_exhausted = false

var current_mask = 1
var jump_speed = 500
#var gravity = 200
var default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity: int = default_gravity

var y_vel = 0
var max_y_vel = 300

#controllers
var attack = false
var	switch_form = false
var skill = false
var up = false
var down = false
	
func play(animation: String, fliph = false, flipv= false) -> void:
	_animated_sprite.set_flip_h(fliph)
	_animated_sprite.set_flip_v(flipv)
	_animated_sprite.play(animation)

func _ready() -> void:
#	regenEnergyTimer.start()
	pass

func _process(delta: float) -> void:
	attack = Input.is_action_just_pressed("attack")
	switch_form = Input.is_action_pressed("switch_form")
	skill = Input.is_action_just_pressed("skill")
	if is_casted_off and not is_exhausted:
		up = Input.is_action_pressed("ui_up")
		down = Input.is_action_pressed("ui_down")
	else:
		up = Input.is_action_just_pressed("ui_up")
		down = Input.is_action_just_pressed("ui_down")
	
func _physics_process(delta):
	if is_exhausted:
		destroy()
	
	if position.x < stable_position and not crashed:
		if abs(position.x - stable_position) >=1:
			crashed = true
			await destroy()
		else:
			position.x = stable_position

	if is_switching_form and not is_exhausted:
		if is_casted_off:
			play("put_on")
			await _animated_sprite.animation_finished
			regenEnergyTimer.start()
			is_casted_off = false
			if is_in_speed_force: clockupTimer.emit_signal("timeout")
		else:
			play("cast_off")
			await _animated_sprite.animation_finished
			regenEnergyTimer.stop()
			is_casted_off = true
		is_switching_form = false
	elif is_casted_off and not is_exhausted:
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
			clock_up()
	else:
		if not grounded and not undergrounded:
			y_vel = min(max_y_vel, y_vel+gravity)
			position.y += y_vel * delta
		elif up and undergrounded:
			emit_signal("walk_underground", false, false, true, false)
			underGroundAudioPlayer.stop()
			y_vel = -jump_speed * 4
			position.y += y_vel * delta
			exiting_underground = true
		#Only allow go underground when the platform's mask contains only "1"
		elif down and grounded and rayCastBottom.get_collider().collision_mask == 1:
			current_mask = 2
			entering_underground = true
			underGroundAudioPlayer.play()
			emit_signal("walk_underground", true, false, false, false)
		elif not up and not exiting_underground:
			if undergrounded:
				emit_signal("walk_underground", false, true, false, false)
			if not is_exhausted:
				play("cocoon_walk")
		
	move_and_collide(velocity * delta)
#	move_and_slide()
	
	if attack:
		thunder_attack(ceil_touched)

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		position.x += direction * 10
	
	if switch_form and not undergrounded:
		if is_casted_off and not putOnAudioPlayer.playing and not castOffAudioPlayer.playing:
			putOnAudioPlayer.play()
		elif not is_casted_off and not castOffAudioPlayer.playing and not putOnAudioPlayer.playing:
			castOffAudioPlayer.play()
		is_switching_form = true
		current_mask = 1
	
	if is_in_speed_force:
		emit_signal("clockup_mode", true, clockupTimer.get_time_left())
	if rayCastBottom.is_colliding() and not rayCastBottom.get_collider() is BaseEnemy:
		var orig = rayCastBottom.global_transform.origin
		var coll = rayCastBottom.get_collision_point()		
		var dist = abs(orig.y - coll.y)
		var depth = abs(rayCastBottom.target_position.y - dist)
		position.y -= depth - 1
		
		if rayCastBottom.get_collision_mask_value(2):
			undergrounded = true
			grounded = false
		else:
			undergrounded = false
			if not grounded:
				current_mask = 1
				grounded = true
		is_ceil_landing = false
		ceil_touched = false
		if exiting_underground and rayCastBottom.get_collider().collision_mask == 1:
			exiting_underground = false
			emit_signal("walk_underground", false, false, false, true)
		if entering_underground and rayCastBottom.get_collider().collision_mask != 1:
			entering_underground = false
	else:
		if undergrounded and current_mask == 2:
			current_mask = 1
		grounded = false
		undergrounded = false
	if rayCastPrepareLanding.is_colliding():
		is_ceil_landing = true
		grounded = false
	else:
		is_ceil_landing = false
	
	if rayCastTop.is_colliding() and not rayCastBottom.get_collider() is BaseEnemy:
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
	
	changeCollisionMask(current_mask)

func _on_hit_box_body_entered(body: Node):
	if body is BaseEnemy:
		crashed = true
		await destroy()

func thunder_attack(is_ceil_touched: bool):
	if energy >= 3:
		energy -= 3
		var thunder_attack_inst = thunder_attack_scn.instantiate()
		thunder_attack_inst.position = Vector2(_animated_sprite.position)
		var _attack_sprite = thunder_attack_inst.get_child(1)
		add_child(thunder_attack_inst, true)
		_attack_sprite.set_flip_v(is_ceil_touched)
		_attack_sprite.play("default")
		await _attack_sprite.animation_finished
		remove_child(thunder_attack_inst)

func changeCollisionMask(mask: int) -> void:
	collision_mask = mask
	rayCastBottom.collision_mask = mask
	_hitbox.collision_mask = mask
 
func destroy() -> void:
	var hitbox = get_node("HitBox")
	if hitbox:
		remove_child(hitbox)
		if is_exhausted and is_casted_off:
			play("exhausted")
			await _animated_sprite.animation_finished
		elif is_exhausted and not is_casted_off:
			play("cocoon_exhausted")
			await _animated_sprite.animation_finished
		var explosion_inst = explosion_scn.instantiate()
		add_child(explosion_inst, true)
		await explosion_inst.animation_finished
		emit_signal("game_over", point)
		queue_free()

func clock_up() -> bool:
	if not clockupTimer.is_stopped() or energy < 5 or is_in_speed_force:
		return false
	clockUpAudioPlayer.play()
	energy -= 2
	is_in_speed_force = true
	var clockup_effect = clockup_speed_scn.instantiate()
	clockup_effect.position = Vector2(-80, 0)
	add_child(clockup_effect, true)
#	_animated_sprite.material.set_shader_parameter("contrast", 2)
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		enemy.velocity /= 12
		enemy.speed /= 12
		enemy.animation_speed /= 3.0
		enemy.gravity /= 12
	emit_signal("clockup_mode", true, clockupTimer.get_time_left())
	clockupTimer.start()
	return true

func _on_regen_energy_timer_timeout() -> void:
	energy += 1

func _on_clock_over() -> void:
	clockOverAudioPlayer.play()
	is_in_speed_force = false
	clockupTimer.stop()
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for enemy in enemies:
		if enemy.speed < enemy.default_speed:
			enemy.speed *= 12
			enemy.gravity = default_gravity
			enemy.animation_speed = enemy.default_animation_speed
	var regex = RegEx.new()
	regex.compile("clockUpEffect")
	var clock_up_effect = get_children().filter(func (node): return regex.search(node.name )).front()
	if clock_up_effect:
		remove_child(clock_up_effect)
	emit_signal("clockup_mode", false, 0)


func _on_stamina_timer_timeout() -> void:
	if is_casted_off:
		stamina -= 0.8
	else:
		stamina -= 0.4
	if stamina == 0 and not crashed:
		is_exhausted = true
